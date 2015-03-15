//
//  VStreamCollectionCell-D.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionCellD.h"
#import "VStreamCellActionViewD.h"
#import "VSequence+Fetcher.h"
#import "VThemeManager.h"
#import "NSString+VParseHelp.h"

const CGFloat kTemplateDHeaderHeight = 50.0f;
const CGFloat kTemplateDActionViewHeight = 41.0f;
static const CGFloat kTextViewInset = 58.0f; //Needs to be sum of textview inset from left and right

const CGFloat kTemplateDActionViewBottomConstraintHeight = 28.0f; //This represents the space between the bottom of the cell and the actionView

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kTemplateDTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VStreamCollectionCellD ()

@property (nonatomic, weak) IBOutlet VStreamCellActionViewD *actionView;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;

@end

@implementation VStreamCollectionCellD

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.actionViewBottomConstraint.constant = kTemplateDActionViewBottomConstraintHeight;
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:@"VStreamCollectionCell-D"
                          bundle:nil];
}

- (NSString *)headerNibName
{
    return @"VStreamCellHeaderView-C";
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
    self.actionView.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kTemplateDTextNeighboringViewSeparatorHeight;
}

- (void)reloadCommentsCount
{
    [(VStreamCellActionViewD *)self.actionView updateCommentsCount:[self.sequence commentCount]];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.actionView.sequence = sequence;
    [self setupActionBar];
    [self reloadCommentsCount];
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

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width + kTemplateDHeaderHeight + kTemplateDActionViewHeight + kTemplateDActionViewBottomConstraintHeight;
    return CGSizeMake(width, height);
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];

    CGFloat width = actual.width - kTextViewInset - kCaptionTextViewLineFragmentPadding * 2;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        //Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributes]];
        actual.height += textSize.height + kTemplateDTextNeighboringViewSeparatorHeight; //Neighboring space adds space BELOW the captionTextView
    }
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
