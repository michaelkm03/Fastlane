//
//  VContentCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentsCell.h"

// Subviews
#import "VCommentTextAndMediaView.h"

// Theme
#import "VThemeManager.h"

static const UIEdgeInsets kTextInsets        = { 36.0f, 56.0f, 11.0f, 25.0f };

static const CGFloat kImagePreviewLoadedAnimationDuration = 0.25f;

static NSCache *_sharedImageCache = nil;

@interface VContentCommentsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *commentersAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentersUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *realtimeCommentLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorImageView;
@property (weak, nonatomic) IBOutlet VCommentTextAndMediaView *commentAndMediaView;
@property (weak, nonatomic) IBOutlet UIImageView *clockIconImageView;

@end

@implementation VContentCommentsCell

+ (NSCache *)sharedImageCached
{
    if ( !_sharedImageCache )
    {
        _sharedImageCache = [[NSCache alloc] init];
    }
    return _sharedImageCache;
}

+ (void)clearSharedImageCache
{
    _sharedImageCache = nil;
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), 70.0f);
}

+ (CGSize)sizeWithFullWidth:(CGFloat)width
                commentBody:(NSString *)commentBody
                andHasMedia:(BOOL)hasMedia
{
    CGFloat textHeight = [VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right)
                                                                       text:commentBody
                                                                  withMedia:hasMedia
                                                                    andFont:[[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont]];
    CGFloat finalHeight = textHeight + kTextInsets.top + kTextInsets.bottom;
    return CGSizeMake(width, finalHeight);
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.seperatorImageView.image = [self.seperatorImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.seperatorImageView.tintColor = [UIColor colorWithRed:229/255.0f green:229/255.0f blue:229/255.0f alpha:1.0f];
    
    self.commentersAvatarImageView.layer.cornerRadius = CGRectGetWidth(self.commentersAvatarImageView.bounds) * 0.5f;
    self.commentersAvatarImageView.layer.cornerRadius = CGRectGetHeight(self.commentersAvatarImageView.bounds) * 0.5f;
    self.commentersAvatarImageView.layer.masksToBounds = YES;
    self.commentersAvatarImageView.image = [self.commentersAvatarImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.commentersAvatarImageView.tintColor = [UIColor lightGrayColor];
    
    self.commentAndMediaView.preferredMaxLayoutWidth = CGRectGetWidth(self.commentAndMediaView.frame);

    [self prepareContentAndMediaView];
    
    self.commentersUsernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    self.commentersUsernameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.timestampLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.realtimeCommentLocationLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.commentAndMediaView.textFont = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
}

- (void)prepareContentAndMediaView
{
    [self.commentAndMediaView resetView];
    self.commentAndMediaView.hasMedia = NO;
    self.commentAndMediaView.mediaThumbnailView.image = nil;
    self.commentAndMediaView.mediaThumbnailView.hidden = YES;
    
    self.commentAndMediaView.onMediaTapped = ^(void)
    {
        [self tappedOnMedia];
    };
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.onUserProfileTapped = nil;
    self.commentersAvatarImageView.image = nil;
    
    [self prepareContentAndMediaView];
}

#pragma mark - Target/Action

- (void)tappedOnMedia
{
    if (self.onMediaTapped && self.commentAndMediaView.mediaThumbnailView.image)
    {
        self.onMediaTapped();
    }
}

- (IBAction)tappedOnProfileImage:(id)sender
{
    if (self.onUserProfileTapped)
    {
        self.onUserProfileTapped();
    }
}

#pragma mark - Property Accessor

- (void)setHasMedia:(BOOL)hasMedia
{
    _hasMedia = hasMedia;
    self.commentAndMediaView.mediaThumbnailView.hidden = !hasMedia;
    self.commentAndMediaView.hasMedia = hasMedia;
}

- (void)setMediaPreviewURL:(NSURL *)mediaPreviewURL
{
    _mediaPreviewURL = [mediaPreviewURL copy];
    [self loadImageWithURL:_mediaPreviewURL intoImageView:self.commentAndMediaView.mediaThumbnailView withImageCache:[[self class] sharedImageCached]];
}

- (void)loadImageWithURL:(NSURL *)url intoImageView:(UIImageView *)imageView withImageCache:(NSCache *)imageCache
{
    NSParameterAssert( imageView != nil );
    NSParameterAssert( imageCache != nil );
    
    if ( url == nil )
    {
        imageView.image = nil;
        return;
    }
    
    __block NSString *keyString = url.absoluteString;
    UIImage *cachedImage = [imageCache objectForKey:keyString];
    
    if ( cachedImage != nil && [cachedImage isKindOfClass:[UIImage class]] )
    {
        [imageView setImage:cachedImage];
    }
    else
    {
        imageView.alpha = 0.0f;
        [self.commentAndMediaView.mediaThumbnailView setImageWithURLRequest:[NSURLRequest requestWithURL:url]
                                                           placeholderImage:nil
                                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
         {
             [imageView setImage:image];
             [UIView animateWithDuration:kImagePreviewLoadedAnimationDuration animations:^{
                 imageView.alpha = 1.0f;
             }];
             [imageCache setObject:image forKey:keyString];
             
         } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
             imageView.image = nil;
         }];
    }
}

- (void)setMediaIsVideo:(BOOL)mediaIsVideo
{
    _mediaIsVideo = mediaIsVideo;
    self.commentAndMediaView.playIcon.hidden = !mediaIsVideo;
}

- (void)setCommentBody:(NSString *)commentBody
{
    _commentBody = [commentBody  copy];
    self.commentAndMediaView.text = commentBody;
}

- (void)setCommenterName:(NSString *)commenterName
{
    _commenterName = [commenterName copy];
    self.commentersUsernameLabel.text = commenterName;
}

- (void)setURLForCommenterAvatar:(NSURL *)URLForCommenterAvatar
{
    _URLForCommenterAvatar = [URLForCommenterAvatar copy];
    
    [self loadImageWithURL:_URLForCommenterAvatar intoImageView:self.commentersAvatarImageView withImageCache:[[self class] sharedImageCached]];
}

- (void)setTimestampText:(NSString *)timestampText
{
    _timestampText = [timestampText copy];
    self.timestampLabel.text = timestampText;
}

- (void)setRealTimeCommentText:(NSString *)realTimeCommentText
{
    _realTimeCommentText = [realTimeCommentText copy];
    
    self.realtimeCommentLocationLabel.text  = realTimeCommentText;
    self.clockIconImageView.hidden = (!realTimeCommentText || (realTimeCommentText.length < 1));
}

- (UIImage *)previewImage
{
    return self.commentAndMediaView.mediaThumbnailView.image;
}

- (UIView *)previewView
{
    return self.commentAndMediaView.mediaThumbnailView;
}

@end
