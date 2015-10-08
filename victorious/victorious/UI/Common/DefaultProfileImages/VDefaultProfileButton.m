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
#import "victorious-Swift.h"

static NSString * const kMinUserLevelKey = @"minLevel";
static NSString * const kAvatarBadgeLevelViewKey = @"avatarBadgeLevelView";

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
    self.imageView.layer.cornerRadius = self.bounds.size.width / 2;
    self.imageView.layer.masksToBounds = YES;
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
         else
         {
             [strongSelf setImage:image forState:UIControlStateNormal];
         }
     }];
}

- (void)setLevelBadgeImageType:(VLevelBadgeImageType)levelBadgeImageType
{
    _levelBadgeImageType = levelBadgeImageType;
    [self updateBadgeViewContent];
}

- (void)updateBadgeViewContent
{
    if ( self.levelBadgeView != nil && self.user != nil )
    {
        NSNumber *userLevel = self.user.level;
        NSNumber *minimumLevel = [self.levelBadgeView.badgeDependencyManager numberForKey:kMinUserLevelKey];
        self.levelBadgeView.hidden = userLevel.integerValue < minimumLevel.integerValue;
        self.levelBadgeView.level = userLevel.integerValue;
        self.levelBadgeView.isCreator = self.user.isCreator.boolValue;
        self.levelBadgeView.levelBadgeImageType = self.levelBadgeImageType;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if ( self.levelBadgeView != nil && self.user != nil )
    {
        CGRect currentBounds = self.bounds;
        CGFloat radius = CGRectGetWidth(currentBounds) / 2;
        CGFloat spotOnCircle = radius + sqrt(pow(radius, 2) / 2);
        CGSize desiredSize = self.levelBadgeView.desiredSize;
        CGRect badgeFrame = CGRectZero;
        badgeFrame.size = desiredSize;
        badgeFrame.origin.x = VFLOOR(spotOnCircle - desiredSize.width / 2);
        badgeFrame.origin.y = VFLOOR(spotOnCircle - desiredSize.height / 2);
        self.levelBadgeView.frame = badgeFrame;
    }
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self setNeedsLayout];
}

- (void)setDependencyManager:(VDependencyManager *__nullable)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        [self updateBadgeViewContent];
    }
}

- (void)setUser:(VUser *__nullable)user
{
    _user = user;
    [self setProfileImageURL:[NSURL URLWithString:user.pictureUrl] forState:UIControlStateNormal];
    [self updateBadgeViewContent];
}

- (AvatarLevelBadgeView *)levelBadgeView
{
    if ( self.dependencyManager == nil || _levelBadgeView != nil )
    {
        return _levelBadgeView;
    }
    
    _levelBadgeView = [self.dependencyManager templateValueOfType:[AvatarLevelBadgeView class] forKey:kAvatarBadgeLevelViewKey];
    [self addSubview:_levelBadgeView];
    return _levelBadgeView;
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
    if ( self.levelBadgeView != nil && view == self.levelBadgeView )
    {
        return self;
    }
    return view;
}

@end
