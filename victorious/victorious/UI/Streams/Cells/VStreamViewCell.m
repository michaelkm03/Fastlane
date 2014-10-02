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

#import "NSLayoutManager+VTableViewCellSupport.h"

@interface VStreamViewCell() <VEphemeralTimerViewDelegate>

@property (nonatomic) BOOL                          animating;
@property (nonatomic) NSUInteger                    originalHeight;

@property (nonatomic, strong) VEphemeralTimerView   *ephemeralTimerView;
@property (nonatomic, strong) NSArray               *hashTagRanges;

@property (nonatomic, strong) NSTextStorage         *textStorage;
@property (nonatomic, strong) NSLayoutManager       *layoutManager;

@end

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.originalHeight = self.frame.size.height;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    // Setup the layoutmanager, text container, and text storage (see also NSLayoutManager+VTableViewCellSupport)
    self.layoutManager = [[NSLayoutManager alloc] init]; // no delegate currently being used
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.bounds.size];
    textContainer.widthTracksTextView = YES;
    textContainer.heightTracksTextView = YES;
    [self.layoutManager addTextContainer:textContainer];
    self.textStorage = [[NSTextStorage alloc] init];
    [self.textStorage addLayoutManager:self.layoutManager];
    
    // Create text view and customize any further
    self.descriptionTextView = [self createTappableTextViewInSuperView:self.overlayView withTextContainer:textContainer];
    self.descriptionTextView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textTapped:)];
    [self.descriptionTextView  addGestureRecognizer:tap];
    
    self.ephemeralTimerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VEphemeralTimerView class]) owner:self options:nil] firstObject];
    self.ephemeralTimerView.delegate = self;
    self.ephemeralTimerView.center = self.center;
    [self addSubview:self.ephemeralTimerView];
 
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"VStreamCellHeaderView" owner:self options:nil] objectAtIndex:0];
    [self addSubview:self.streamCellHeaderView];
    
    [self addSubview:self.commentHitboxButton];
}

- (UITextView *)createTappableTextViewInSuperView:(UIView *)targetSuperview withTextContainer:(NSTextContainer *)textContainer
{
    UITextView *textView = [[UITextView alloc] initWithFrame:self.bounds textContainer:textContainer];
    textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor whiteColor];
    textView.translatesAutoresizingMaskIntoConstraints = NO;
    textView.editable = NO;
    textView.selectable = NO;
    textView.scrollEnabled = NO;
    textView.textContainerInset = UIEdgeInsetsZero; // leave this as zero. To inset the text, adjust the textView's frame instead.
    [targetSuperview addSubview:textView];
    
    NSDictionary *views = @{ @"textView" : textView };
    [targetSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[textView]-21-|" options:0 metrics:nil views:views]];
    [targetSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textView]-21-|" options:0 metrics:nil views:views]];
    
    textView.textContainer.size = textView.superview.bounds.size;
    
    return textView;
}

- (void)textTapped:(UITapGestureRecognizer *)tap
{
    if ( tap.view != nil && [tap.view isKindOfClass:[UITextView class]] )
    {
        UITextView *textView = (UITextView *)tap.view;
        [self detectHashTagsInTextView:textView atPoint:[tap locationInView:textView] detectionCallback:^(NSString *hashTag) {
            [self hashTagTapped:hashTag];
        }];
    }
}

- (void) detectHashTagsInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *hashTag))callback
{
    // Error checking + optimization
    if ( textView == nil || textView.layoutManager == nil || textView.textContainer == nil || textView.text.length == 0 )
    {
        return;
    }
    
    NSString *fieldText = textView.text;
    NSArray *hashTags = [VHashTags detectHashTags:fieldText];
    if ( hashTags.count == 0 )
    {
        return;
    }

    [hashTags enumerateObjectsUsingBlock:^(NSValue *hastagRangeValue, NSUInteger idx, BOOL *stop) {
         
         NSRange tagRange = [hastagRangeValue rangeValue];
         CGRect rect = [textView.layoutManager boundingRectForGlyphRange:tagRange inTextContainer:textView.textContainer];
         NSUInteger margin = 10;
         rect.origin.y -= margin;
         rect.size.height += margin * 2.0;
         if ( CGRectContainsPoint(rect, tapPoint) )
         {
             if ( callback != nil )
             {
                 callback( [fieldText substringWithRange:tagRange] );
             }
             *stop = YES;
         }
     }];
}

- (void) hashTagTapped:(NSString *)hashTag
{
    if ([self.delegate respondsToSelector:@selector(hashTagButtonTappedInStreamViewCell:withTag:)])
    {
        [self.delegate hashTagButtonTappedInStreamViewCell:self withTag:hashTag];
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

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_sequence.previewImage]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:[UIImage resizeableImageWithColor:
                                                   [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         if (!request)
         {
             self.previewImageView.image = image;
             return;
         }
         
         self.previewImageView.alpha = 0;
         self.previewImageView.image = image;
         [UIView animateWithDuration:.3f
                          animations:^
          {
              self.previewImageView.alpha = 1;
          }];
     }
                                          failure:nil];
    
    // Check if being viewed from the User Profile
    if ([self.parentTableViewController isKindOfClass:[VUserProfileViewController class]])
    {
        [self.streamCellHeaderView setIsFromProfile:YES];
    }

    
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

- (IBAction)commentButtonAction:(id)sender
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

- (void) hideOverlays
{
    self.overlayView.alpha = 0;
    self.shadeView.alpha = 0;
    self.animationImage.alpha = 0;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height);
}

- (void) showOverlays
{
    self.overlayView.alpha = 1;
    self.shadeView.alpha = 1;
    self.animationImage.alpha = 1;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y);
}

@end
