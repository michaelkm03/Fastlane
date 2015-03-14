//
//  VStreamCollectionCellPollD.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCellPollD.h"
#import "VAnswer.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VThemeManager.h"
#import "VStreamCellActionViewD.h"
#import "VStreamCollectionCellD.h"
#import "NSString+VParseHelp.h"
#import <CCHLinkTextView.h>

@interface VStreamCollectionCellPollD ()

@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@property (nonatomic, weak) IBOutlet UIView *captionContainerView;

@property (nonatomic, weak) IBOutlet VStreamCellActionViewD *actionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionContainerHeightConstraint;

@end

@implementation VStreamCollectionCellPollD

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.captionContainerView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor];

    self.actionViewBottomConstraint.constant = kTemplateDActionViewBottomConstraintHeight;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray *answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupActionBar];
    [self setupMedia];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    
    //Add the "comments" button
    [(VStreamCellActionViewD *)self.actionView addCommentsButton];
    
    [self.actionView addShareButton];
    if ( [self.sequence canRemix] )
    {
        [self.actionView addRemixButton];
    }
    if ( [self.sequence canRepost] )
    {
        [self.actionView addRepostButton];
    }
    [self.actionView addMoreButton];
}

- (void)setDelegate:(id<VSequenceActionsDelegate>)delegate
{
    [super setDelegate:delegate];
    self.actionView.delegate = delegate;
}

- (void)setupMedia
{
    self.firstAssetUrl = [NSURL URLWithString: self.firstAnswer.thumbnailUrl];
    self.secondAssetUrl = [NSURL URLWithString:self.secondAnswer.thumbnailUrl];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    
    [self.previewImageView fadeInImageAtURL:self.firstAssetUrl
                           placeholderImage:placeholderImage];
    
    [self.previewImageTwo fadeInImageAtURL:self.secondAssetUrl
                          placeholderImage:placeholderImage];
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    CGFloat constraintValue = zeroConstraints ? 0.0f : kTemplateDTextNeighboringViewSeparatorHeight;
    self.captionTextViewTopConstraint.constant = constraintValue;
    self.captionTextViewBottomConstraint.constant = constraintValue;
    
    CGSize textSize = [text frameSizeForWidth:CGRectGetWidth(self.captionTextView.bounds)
                                andAttributes:[[self class] sequenceDescriptionAttributes]];
    
    self.captionContainerHeightConstraint.constant = constraintValue * 2 + textSize.height;
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

- (NSString *)headerNibName
{
    return @"VStreamCellHeaderView-C";
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width + kTemplateDHeaderHeight + kTemplateDActionViewHeight + kTemplateDActionViewBottomConstraintHeight); //width * kTemplateCPollContentRatio represents the desired media height
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    return [self desiredSizeWithCollectionViewBounds:bounds];
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:@"VStreamCollectionCellPoll-D"
                          bundle:nil];
}

+ (NSDictionary *)sequenceDescriptionAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[ NSFontAttributeName ] = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    attributes[ NSForegroundColorAttributeName ] = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
