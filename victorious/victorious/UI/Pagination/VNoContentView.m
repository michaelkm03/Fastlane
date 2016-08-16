//
//  VNoContentView.m
//  victorious
//
//  Created by Will Long on 6/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentView.h"
#import "VDependencyManager.h"

// Should match constraints from xib
static CGFloat const kPaddingTop = 96.0f;
static CGFloat const kImageHeight = 53.0f;
static CGFloat const kIconToTitleSpace = 40.0f;
static CGFloat const kTitleToMessageSpace = 20.0f;
static CGFloat const kPaddingBottom = 50.0f;
static CGFloat const kPreferredWidthOfMessage = 190.0f;

static NSString * const kTitleFontKey = @"font.heading1";
static NSString * const kMessageFontKey = @"font.heading4";

@interface VNoContentView ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;

@end

@implementation VNoContentView

+ (instancetype)viewFromNibWithFrame:(CGRect)frame
{
    VNoContentView *noContentView = [[[NSBundle mainBundle] loadNibNamed:@"VNoContentView" owner:nil options:nil] objectAtIndex:0];
    
    noContentView.frame = frame;

    return noContentView;
}

#pragma mark - VHasManagedDependencies

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.titleLabel.font = [dependencyManager fontForKey:kTitleFontKey];
        self.messageLabel.font = [dependencyManager fontForKey:kMessageFontKey];
        self.titleLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        self.messageLabel.textColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        self.iconImageView.tintColor = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
}

#pragma mark - Property Accessors

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
}

- (NSString *)message
{
    return self.messageLabel.text;
}

- (void)setIcon:(UIImage *)icon
{
    self.iconImageView.image = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (UIImage *)icon
{
    return self.iconImageView.image;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds titleString:(NSString *)titleString messageString:(NSString *)messageString andDependencyManager:(VDependencyManager *)dependencyManager
{
    NSAssert( dependencyManager != nil, @"dependency manager was not set");
    
    CGSize size = CGSizeZero;
    
    if ( dependencyManager != nil )
    {
        UIFont *titleFont = [dependencyManager fontForKey:kTitleFontKey];
        UIFont *messageFont = [dependencyManager fontForKey:kMessageFontKey];
        CGRect frameTitle = [titleString boundingRectWithSize:CGSizeMake(kPreferredWidthOfMessage, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:titleFont } context:nil];
        CGFloat titleHeight = CGRectGetHeight(frameTitle);
        CGRect frameMessage = [messageString boundingRectWithSize:CGSizeMake(kPreferredWidthOfMessage, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:messageFont } context:nil];
        CGFloat messageHeight = CGRectGetHeight(frameMessage);
        
        CGFloat totalHeight = kPaddingTop + kPaddingBottom + kImageHeight + kIconToTitleSpace + kTitleToMessageSpace + titleHeight + messageHeight;
        
        size = CGSizeMake(CGRectGetWidth(bounds), totalHeight);
    }
    else
    {
        size = CGSizeMake(CGRectGetWidth(bounds), 400);
    }

    return size;
}

- (void)resetInitialAnimationState
{
    self.alpha = 0.0;
    const CGFloat scale = 0.8f;
    self.transform = CGAffineTransformMakeScale( scale, scale );
}

- (void)animateTransitionIn
{
    [UIView animateWithDuration:0.5f
                          delay:0.2f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^
     {
         self.alpha = 1.0f;
         self.transform = CGAffineTransformIdentity;
     } completion:nil];
}

@end
