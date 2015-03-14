//
//  VStreamCollectionCellC.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCellC.h"
#import "VThemeManager.h"
#import "VStreamCellActionView.h"
#import "VSequence+Fetcher.h"
#import "NSString+VParseHelp.h"

//IMPORTANT: these template C constants much match up with the heights of values from the VStreamCollectionCell-C xib
static const CGFloat kXRatio = 0.94375f; // 320/302
static const CGFloat kHeaderHeight = 50.0f;
static const CGFloat kActionViewHeight = 41.0f;
const CGFloat kTemplateCTextViewInset = 20.0f; //Needs to be sum of textview inset from left and right

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kTemplateCTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it
const CGFloat kTemplateCTextSeparatorHeight = 6.0f; //This represents the space between the label and textView. It's slightly smaller than the those separating the label and textview from their respective bottom and top to neighboring views so that the centers of words are better aligned

@interface VStreamCollectionCellC ()

@property (nonatomic, weak) IBOutlet VStreamCellActionView *actionView;

@property (nonatomic, weak) IBOutlet UILabel *commentsLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentsLeftConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentLabelBottomConstraint;

@end

@implementation VStreamCollectionCellC

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.commentsLabel.font = [[[self class] sequenceCommentCountAttributes] objectForKey:NSFontAttributeName];
    self.commentsLeftConstraint.constant = - kCaptionTextViewLineFragmentPadding;
    
    self.commentLabelBottomConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
    self.captionTextViewTopConstraint.constant = kTemplateCTextNeighboringViewSeparatorHeight;
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:@"VStreamCollectionCell-C"
                          bundle:nil];
}

+ (NSDictionary *)sequenceCommentCountAttributes
{
    return @{ NSFontAttributeName : [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font] };
}

- (NSString *)headerNibName
{
    return @"VStreamCellHeaderView-C";
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

- (void)setDelegate:(id<VSequenceActionsDelegate>)delegate
{
    [super setDelegate:delegate];
    self.actionView.delegate = delegate;
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

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.actionView.sequence = sequence;
    [self reloadCommentsCount];
    [self setupActionBar];
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

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    width *= kXRatio;
    CGFloat height = width + kHeaderHeight + kActionViewHeight + kTemplateCTextNeighboringViewSeparatorHeight * 2.0f; //Width represents the desired media height, there are 2 neighboring separators (top to textview and bottom to comment label) in addition to one constraint between the comment count label and the textview.
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

+ (NSDictionary *)sequenceDescriptionAttributes
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[ NSFontAttributeName ] = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    attributes[ NSForegroundColorAttributeName ] = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    attributes[ NSParagraphStyleAttributeName ] = [[NSMutableParagraphStyle alloc] init];
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
