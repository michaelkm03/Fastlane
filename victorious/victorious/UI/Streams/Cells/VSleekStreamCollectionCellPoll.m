//
//  VStreamCollectionCellPollD.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCollectionCellPoll.h"
#import "VAnswer.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VThemeManager.h"
#import "UIImage+ImageCreation.h"
#import "UIImageView+VLoadingAnimations.h"
#import "VSleekStreamCellActionView.h"
#import "VSleekStreamCollectionCell.h"
#import "NSString+VParseHelp.h"
#import <CCHLinkTextView.h>
#import "VDependencyManager.h"

@interface VSleekStreamCollectionCellPoll ()

//Poll-specific datas
@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@property (nonatomic, weak) IBOutlet UIView *captionContainerView; ///< A view that will enclose the caption text view and expand to accomodate the cell text
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionContainerHeightConstraint;

@end

@implementation VSleekStreamCollectionCellPoll

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.actionViewBottomConstraint.constant = kSleekCellActionViewBottomConstraintHeight;
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
    
    [self setupMedia];
}

//Sets up poll content
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
    
    //Update constraints to accomodate newly passed in text
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    CGFloat constraintValue = zeroConstraints ? 0.0f : kSleekCellTextNeighboringViewSeparatorHeight;
    
    CGSize textSize = [text frameSizeForWidth:CGRectGetWidth(self.captionTextView.bounds)
                                andAttributes:[[self class] sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
    
    //Adjust container height to be textHeight + textView top and bottom inset. This will expand over the top of the poll images.
    self.captionContainerHeightConstraint.constant = constraintValue * 2 + textSize.height;
    self.captionTextViewTopConstraint.constant = constraintValue;
    self.captionTextViewBottomConstraint.constant = constraintValue;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( dependencyManager )
    {
        //Superclass method will take care of passing dependencyManager down to actionView
        [super setDependencyManager:dependencyManager];
        self.captionContainerView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    }
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width + kSleekCellHeaderHeight + kSleekCellActionViewHeight + kSleekCellActionViewBottomConstraintHeight);
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self desiredSizeWithCollectionViewBounds:bounds];
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if ( dependencyManager )
    {
        attributes[ NSFontAttributeName ] = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    }
    attributes[ NSForegroundColorAttributeName ] = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
