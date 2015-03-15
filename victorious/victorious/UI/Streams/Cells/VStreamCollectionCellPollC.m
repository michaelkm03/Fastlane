//
//  VStreamCollectionCellPollC.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCellPollC.h"
#import "VAnswer.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VStreamCellActionView.h"
#import "VStreamCollectionCellC.h"
#import "NSString+VParseHelp.h"

//IMPORTANT: these template C constants much match up with the heights of values from the VStreamCollectionCellPoll-C xib
static const CGFloat kTemplateCPollCellWidthRatio = 0.94375f; // 320/302
static const CGFloat kTemplateCPollContentRatio = 0.6688741722f; // 202/302
static const CGFloat kTemplateCHeaderHeight = 50.0f;
static const CGFloat kTemplateCActionViewHeight = 41.0f;

@interface VStreamCollectionCellPollC ()

@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@property (nonatomic, weak) IBOutlet VStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentsLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;

@end

@implementation VStreamCollectionCellPollC

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.commentsLabel.font = [[[self class] sequenceCommentCountAttributes] objectForKey:NSFontAttributeName];
    self.commentsLeftConstraint.constant = - kCaptionTextViewLineFragmentPadding;
    
    self.commentLabelBottomConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
    self.captionTextViewTopConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
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
    [self reloadCommentsCount];
    [self setupMedia];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    
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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    self.actionView.dependencyManager = dependencyManager;
    [self.commentsLabel setTextColor:[self textColor]];
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
    
    //Remove the space between label and textView if the textView is empty
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kTemplateCTextSeparatorHeight;
}

- (void)reloadCommentsCount
{
    NSNumber *commentCount = [self.sequence commentCount];
    NSString *commentsString = [NSString stringWithFormat:@"%@ %@", [commentCount stringValue], [commentCount integerValue] == 1 ? NSLocalizedString(@"Comment", @"") : NSLocalizedString(@"Comments", @"")];
    [self.commentsLabel setText:commentsString];
    self.commentHeightConstraint.constant = [commentsString sizeWithAttributes:@{ NSFontAttributeName : self.commentsLabel.font }].height;
}

- (NSString *)headerNibName
{
    return @"VStreamCellHeaderView-C";
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    width = floorf(width * kTemplateCPollCellWidthRatio);
    CGFloat height = floorf(width * kTemplateCPollContentRatio + kTemplateCHeaderHeight + kTemplateCTextNeighboringViewSeparatorHeight * 2.0f + kTemplateCActionViewHeight); //width * kTemplateCPollContentRatio represents the desired media height
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];
    
    CGFloat width = actual.width - kTemplateCTextViewInset - kCaptionTextViewLineFragmentPadding * 2;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        //Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributes]];
        actual.height += textSize.height + kTemplateCTextSeparatorHeight;
    }
    
    CGSize textSize = [[sequence.commentCount stringValue] frameSizeForWidth:width
                                                               andAttributes:[self sequenceCommentCountAttributes]];
    actual.height += textSize.height;
    return actual;
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:@"VStreamCollectionCellPoll-C"
                          bundle:nil];
}

+ (NSDictionary *)sequenceDescriptionAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[ NSFontAttributeName ] = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    attributes[ NSForegroundColorAttributeName ] = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    attributes[ NSParagraphStyleAttributeName ] = [[NSMutableParagraphStyle alloc] init];
    return [NSDictionary dictionaryWithDictionary:attributes];
}

+ (NSDictionary *)sequenceCommentCountAttributes
{
    return @{ NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] };
}

@end
