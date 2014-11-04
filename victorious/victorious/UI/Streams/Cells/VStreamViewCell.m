//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
#import "VStreamCellHeaderView.h"
#import "VStreamTableViewController.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"

#import "VHashTags.h"

#import "VUserProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"

#import "VConstants.h"

#import "VCommentCell.h"

#import "VEphemeralTimerView.h"

#import "UIImageView+VLoadingAnimations.h"

#import "VTappableTextManager.h"

NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";

@interface VStreamViewCell() <VEphemeralTimerViewDelegate, VSequenceActionsDelegate, VTappableTextManagerDelegate>

@property (nonatomic) BOOL                          animating;
@property (nonatomic) NSUInteger                    originalHeight;

@property (nonatomic, strong) VEphemeralTimerView   *ephemeralTimerView;

@property (nonatomic, strong) NSArray               *hashTagRanges;
@property (nonatomic, strong) NSTextStorage         *textStorage;
@property (nonatomic, strong) NSLayoutManager       *containerLayoutManager;
@property (nonatomic, strong) NSTextContainer       *textContainer;
@property (nonatomic, strong) VTappableTextManager     *tappableTextManager;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalHeight = self.frame.size.height;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    // Setup the layoutmanager, text container, and text storage
    self.containerLayoutManager = [[NSLayoutManager alloc] init]; // no delegate currently being used
    self.textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    self.textContainer.widthTracksTextView = YES;
    self.textContainer.heightTracksTextView = YES;
    [self.containerLayoutManager addTextContainer:self.textContainer];
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage addLayoutManager:self.containerLayoutManager];
    
    NSError *error = nil;
    self.tappableTextManager = [[VTappableTextManager alloc] init];
    if ( ![self.tappableTextManager setDelegate:self error:&error] )
    {
        VLog( @"Error setting delegate: %@", error.domain );
    }
    
    // Create text view and customize any further
    self.descriptionTextView = [self.tappableTextManager createTappableTextViewWithFrame:self.bounds];
    [self.overlayView addSubview:self.descriptionTextView ];
    
    NSDictionary *views = @{ @"textView" : self.descriptionTextView };
    [self.descriptionTextView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textView]-21-|" options:0 metrics:nil views:views]];
    [self.descriptionTextView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textView]-21-|" options:0 metrics:nil views:views]];
    self.descriptionTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.descriptionTextView.textContainer.size = self.descriptionTextView.superview.bounds.size;
    
    self.ephemeralTimerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VEphemeralTimerView class]) owner:self options:nil] firstObject];
    self.ephemeralTimerView.delegate = self;
    self.ephemeralTimerView.center = self.center;
    [self addSubview:self.ephemeralTimerView];
    
 
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"VStreamCellHeaderView" owner:self options:nil] objectAtIndex:0];
    self.streamCellHeaderView.delegate = self;
    [self addSubview:self.streamCellHeaderView];
    
    [self addSubview:self.commentHitboxButton];
}

- (void)text:(NSString *)text tappedInTextView:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(hashTagButtonTappedInStreamViewCell:withTag:)])
    {
        [self.delegate hashTagButtonTappedInStreamViewCell:self withTag:text];
    }
}

- (void)contentExpired
{
//    self.shadeView.backgroundColor = [UIColor whiteColor];
    self.previewImageView.alpha = .5f;
}

- (void)removeExpiredOverlay
{
//    self.shadeView.backgroundColor = [UIColor clearColor];
    self.previewImageView.alpha = 1.0f;
}

- (NSDictionary *)attributesForCellText
{
    //TODO: Remvoe this hardcoded font size
    return @{
             NSFontAttributeName: [[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font] fontWithSize:19],
             NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor],
             };
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self removeExpiredOverlay];

    [self.streamCellHeaderView setSequence:self.sequence];
    [self.streamCellHeaderView setParentViewController:self.parentTableViewController];

    [self.previewImageView fadeInImageAtURL:[NSURL URLWithString:[_sequence.previewImagePaths firstObject]]
                           placeholderImage:[UIImage resizeableImageWithColor:
                                             [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]];
    
    VAsset *firstAsset = [[_sequence firstNode].assets.array firstObject];
    if ([firstAsset.type isEqualToString:VConstantsMediaTypeYoutube])
    {
        self.playButtonImage.hidden = NO;
    }
    else
    {
        self.playButtonImage.hidden = YES;
    }
    
    if (!self.sequence.nameEmbeddedInContent.boolValue)
    {
        NSString *text = self.sequence.name;
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[self attributesForCellText]];
        self.hashTagRanges = [VHashTags detectHashTags:text];
        self.tappableTextManager.tappableTextRanges = self.hashTagRanges;
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = 25;
        paragraphStyle.minimumLineHeight = 25;
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowBlurRadius:4.0f];
        [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
        [shadow setShadowOffset:CGSizeMake(0, 0)];

        if ([self.hashTagRanges count] > 0)
        {
            [VHashTags formatHashTagsInString:newAttributedCellText
                                withTagRanges:self.hashTagRanges
                                   attributes:@{NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]}];
        }
        [newAttributedCellText addAttribute:NSParagraphStyleAttributeName
                                      value:paragraphStyle
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        [newAttributedCellText addAttribute:NSShadowAttributeName
                                      value:shadow
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        
        self.descriptionTextView.attributedText = newAttributedCellText;
    }
    
    self.descriptionTextView.hidden = self.sequence.nameEmbeddedInContent.boolValue;
    
    
    if (_sequence.expiresAt)
    {
        self.ephemeralTimerView.hidden = NO;
        self.ephemeralTimerView.expireDate = _sequence.expiresAt;
        self.animationImage.hidden = YES;
        self.animationBackgroundImage.hidden = YES;
    }
    else
    {
        self.animationImage.hidden = NO;
        self.animationBackgroundImage.hidden = NO;
        self.ephemeralTimerView.hidden = YES;
    }
    
    [self applyConstraintsWithTextView:self.descriptionTextView];
}

- (BOOL)applyConstraintsWithTextView:(UITextView *)textView
{
    if ( textView.superview == nil )
    {
        return NO;
    }
    
    CGFloat width = CGRectGetWidth( textView.frame );
    CGFloat height = [textView sizeThatFits:CGSizeMake( width, CGRectGetHeight( textView.superview.bounds ) * 0.5f )].height;
    NSDictionary *metrics = @{ @"height" : [NSNumber numberWithFloat:height] };
    NSDictionary *views = @{ @"textView" : textView };
    
    NSLayoutConstraint *heightConstraint = nil;
    for ( NSLayoutConstraint *c in textView.constraints )
    {
        if ( c.firstItem == textView && c.firstAttribute == NSLayoutAttributeHeight && c.relation == NSLayoutRelationEqual )
        {
            heightConstraint = c;
            break;
        }
    }
    
    if ( heightConstraint != nil )
    {
        heightConstraint.constant = height;
    }
    else
    {
        [textView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textView(height)]" options:0 metrics:metrics views:views]];
    }
    
    return YES;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (BOOL)remixRepostCheck:(NSString *)sequenceCategory
{
    if ([sequenceCategory rangeOfString:@"remix"].location == NSNotFound && [sequenceCategory rangeOfString:@"repost"].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (void)commentsPressedOnHeader:(VStreamCellHeaderView *)header
{
    if ([self.delegate respondsToSelector:@selector(willCommentOnSequence:inStreamViewCell:)])
    {
        [self.delegate willCommentOnSequence:self.sequence inStreamViewCell:self];
    }

}

- (IBAction)profileButtonAction:(id)sender
{
    //If this cell is from the profile we should disable going to the profile
    BOOL fromProfile = NO;
    for (UIViewController *vc in self.parentTableViewController.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VUserProfileViewController class]])
        {
            fromProfile = YES;
        }
    }
    if (fromProfile)
    {
        return;
    }
    
    VUserProfileViewController *profileViewController = [VUserProfileViewController userProfileWithUser:self.sequence.user];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

- (void)hideOverlays
{
    self.overlayView.alpha = 0;
    self.shadeView.alpha = 0;
    self.animationImage.alpha = 0;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height);
}

- (void)showOverlays
{
    self.overlayView.alpha = 1;
    self.shadeView.alpha = 1;
    self.animationImage.alpha = 1;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y);
}

@end
