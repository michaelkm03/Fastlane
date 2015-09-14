//
//  VDefaultProfileButton.m
//  victorious
//
//  Created by Will Long on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDefaultProfileButton.h"

#import <SDWebImage/UIButton+WebCache.h>
#import "UIImageView+VLoadingAnimations.h"
#import "UIImage+VTint.h"
#import "UIImage+Round.h"
#import "VDependencyManager+VAvatarBadgeAppearance.h"
#import "victorious-Swift.h"

@interface VDefaultProfileButton ()

@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, strong) AvatarLevelBadgeView *levelBadgeView;

@end

@implementation VDefaultProfileButton

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        [self setup];
    }
    return self;
}

- (void)setup
{
    //Setting vertical and horizontal alignment to fill causes the image set by "setImage"
    //to completely fill the bounds of button
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    
    self.backgroundColor = [UIColor clearColor];
    self.tintColor = [UIColor darkGrayColor];
    
    self.borderWidth = 0.0f;
    self.imageEdgeInsets = UIEdgeInsetsZero;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
    
    if ( self.levelBadgeView.superview == nil )
    {
        [self addSubview:self.levelBadgeView];
    }
}

- (void)setTintColor:(UIColor *)tintColor
{
    super.tintColor = [tintColor colorWithAlphaComponent:0.3f];
    // Re-render placeholder image if necessary
    if (_imageURL == nil || [_imageURL absoluteString].length == 0)
    {
        [self setImage:[self placeholderImage] forState:UIControlStateNormal];
    }
}

- (void)setProfileImageURL:(NSURL *)url forState:(UIControlState)controlState
{
    _imageURL = url;
    
    __weak typeof(self) weakSelf = self;
    [[SDWebImageManager sharedManager] downloadImageWithURL:url
                                                    options:SDWebImageRetryFailed
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         __strong typeof(weakSelf) strongSelf = weakSelf;
         
         if (!image)
         {
             [strongSelf setImage:[strongSelf placeholderImage] forState:controlState];
             return;
         }
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^
                        {
                            UIImage *roundedImage = [image roundedImageWithCornerRadius:image.size.height / 2];
                            dispatch_async(dispatch_get_main_queue(), ^
                                           {
                                               [strongSelf setImage:roundedImage forState:controlState];
                                           });
                        });
     }];
}

- (void)setBadgeImageType:(VBadgeImageType)badgeImageType
{
    _badgeImageType = badgeImageType;
    [self updateBadgeViewContent];
}

- (AvatarLevelBadgeView *)levelBadgeView
{
    if ( _levelBadgeView == nil )
    {
        _levelBadgeView = [AvatarLevelBadgeView new];
        [self updateBadgeViewContent];
    }
    return _levelBadgeView;
}

- (void)updateBadgeViewContent
{
    if ( self.dependencyManager != nil )
    {
        NSNumber *userLevel = self.user.level;
        NSNumber *minimumLevel = [self.dependencyManager numberForKey:VDependencyManagerAvatarBadgeAppearanceMinLevelKey];
        self.levelBadgeView.hidden = userLevel.integerValue < minimumLevel.integerValue;
        self.levelBadgeView.badgeBackgroundColor = [self.dependencyManager colorForKey:VDependencyManagerAvatarBadgeAppearanceBackgroundColorKey];
        self.levelBadgeView.textColor = [self.dependencyManager colorForKey:VDependencyManagerAvatarBadgeAppearanceTextColorKey];
        self.levelBadgeView.level = self.user.level.integerValue;
        self.levelBadgeView.isCreator = self.user.isCreator.boolValue;
        self.levelBadgeView.badgeImageType = self.badgeImageType;
        [self updateBadgeViewFrame];
    }
}

- (void)updateBadgeViewFrame
{
    if ( self.dependencyManager != nil )
    {
        CGRect currentBounds = self.bounds;
        CGFloat radius = CGRectGetWidth(currentBounds) / 2;
        CGFloat spotOnCircle = radius + sqrt(pow(radius, 2) / 2);
        CGSize desiredSize = self.levelBadgeView.desiredSize;
        CGRect badgeFrame = CGRectZero;
        badgeFrame.size = desiredSize;
        badgeFrame.origin.x = spotOnCircle - desiredSize.width / 2;
        badgeFrame.origin.y = spotOnCircle - desiredSize.height / 2;
        self.levelBadgeView.frame = badgeFrame;
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self updateBadgeViewFrame];
}

- (void)setDependencyManager:(VDependencyManager *__nullable)dependencyManager
{
    _dependencyManager = dependencyManager.avatarBadgeAppearanceDependencyManager;
    [self updateBadgeViewContent];
}

- (void)setUser:(VUser *__nullable)user
{
    _user = user;
    [self setProfileImageURL:[NSURL URLWithString:user.pictureUrl] forState:UIControlStateNormal];
    [self updateBadgeViewContent];
}

- (UIImage *)placeholderImage
{
    NSString *imageName = @"profile_thumb";
    UIImage *image = [UIImage imageNamed:imageName];
    if (CGRectGetHeight(self.bounds) > image.size.height)
    {
        imageName = @"profile_full";
        image = [UIImage imageNamed:imageName];
    }
    
    // Create unique key from tint color
    NSString *tintKey = [[self.tintColor description] stringByAppendingString:imageName];
    
    // Check cache for already tinted image
    SDImageCache *cache = [[SDWebImageManager sharedManager] imageCache];
    UIImage *cachedImage = [cache imageFromMemoryCacheForKey:tintKey];
    if (cachedImage != nil)
    {
        return cachedImage;
    }
    
    // Tint image and store in cache
    UIImage *tintedImage = [image v_tintedTemplateImageWithColor:self.tintColor];
    [cache storeImage:tintedImage forKey:tintKey];
    
    return tintedImage;
}

- (void)addBorderWithWidth:(CGFloat)width andColor:(UIColor *)color
{
    self.borderWidth = width;
    self.borderColor = color;
    self.imageEdgeInsets = UIEdgeInsetsMake(width, width, width, width);
}

- (void)drawRect:(CGRect)rect
{
    // Draws a white background with a border around the icon if border width is > 0
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddEllipseInRect(context, rect);
    if ( self.borderWidth > 0.0f && self.borderColor != nil )
    {
        CGContextSetFillColorWithColor(context, self.borderColor.CGColor);
        CGContextFillPath(context);
        CGContextAddEllipseInRect(context, CGRectInset(rect, self.borderWidth, self.borderWidth));
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    else
    {
        //Just fill with white
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    }
    CGContextFillPath(context);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if ( view == self.levelBadgeView )
    {
        return self;
    }
    return view;
}

@end
