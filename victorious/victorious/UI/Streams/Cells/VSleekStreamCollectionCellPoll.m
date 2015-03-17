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

@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@property (nonatomic, weak) IBOutlet UIView *captionContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionContainerHeightConstraint;

@end

@implementation VSleekStreamCollectionCellPoll

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
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
    
    [self setupMedia];
}

- (void)reloadCommentsCount
{
    [(VSleekStreamCellActionView *)self.actionView updateCommentsCount:[self.sequence commentCount]];
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
    
    CGSize textSize = [text frameSizeForWidth:CGRectGetWidth(self.captionTextView.bounds)
                                andAttributes:[[self class] sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
    
    self.captionContainerHeightConstraint.constant = constraintValue * 2 + textSize.height;
    self.captionTextViewTopConstraint.constant = constraintValue;
    self.captionTextViewBottomConstraint.constant = constraintValue;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    self.captionContainerView.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    self.actionView.dependencyManager = dependencyManager;
    self.actionView.layer.borderColor = [UIColor clearColor].CGColor;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = floorf(width + kTemplateDHeaderHeight + kTemplateDActionViewHeight + kTemplateDActionViewBottomConstraintHeight);
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self desiredSizeWithCollectionViewBounds:bounds];
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[ NSFontAttributeName ] = [dependencyManager fontForKey:VDependencyManagerHeading3FontKey];
    attributes[ NSForegroundColorAttributeName ] = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
