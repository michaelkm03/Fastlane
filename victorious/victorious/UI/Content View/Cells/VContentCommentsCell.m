//
//  VContentCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentsCell.h"

#import "VUser.h"

// Subviews
#import "VDefaultProfileImageView.h"
#import "VCommentTextAndMediaView.h"

// Dependency Manager
#import "VDependencyManager.h"

// Formatting
#import "UIImage+ImageCreation.h"
#import "AVAsset+Orientation.h"
#import "NSDate+timeSince.h"
#import "VRTCUserPostedAtFormatter.h"
#import "VComment+Fetcher.h"
#import "NSURL+MediaType.h"
#import "UIView+AutoLayout.h"
#import "VTagStringFormatter.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "VTagSensitiveTextView.h"

static const UIEdgeInsets kTextInsets        = { 32.0f, 56.0f, 11.0f, 55.0f };

static const CGFloat kImagePreviewLoadedAnimationDuration = 0.25f;

static NSCache *_sharedImageCache = nil;

@interface VContentCommentsCell ()

@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *commentersAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *commentersUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *realtimeCommentLocationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockIconImageView;

@property (nonatomic, strong) NSNumber *mediaAssetOrientation;
@property (nonatomic, copy) NSURL *URLForCommenterAvatar;
@property (nonatomic, copy) NSString *commenterName;
@property (nonatomic, copy) NSString *timestampText;
@property (nonatomic, copy) NSString *realTimeCommentText;
@property (nonatomic, copy) NSString *commentBody;
@property (nonatomic, assign) BOOL hasMedia;
@property (nonatomic, copy) NSURL *mediaPreviewURL;
@property (nonatomic, assign) BOOL mediaIsVideo;

@property (nonatomic) NSDictionary *tagStringAttributes;
@property (nonatomic) NSDictionary *defaultStringAttributes;

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
                   hasMedia:(BOOL)hasMedia
          dependencyManager:(VDependencyManager *)dependencyManager
{
    CGFloat textHeight = [VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right)
                                                                       text:commentBody
                                                                  withMedia:hasMedia
                                                                    andFont:[dependencyManager fontForKey:VDependencyManagerParagraphFontKey]];
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
    
    self.commentersAvatarImageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setupSwipeView];
    [self.contentView v_addFitToParentConstraintsToSubview:self.swipeViewController.view];
}

- (void)prepareContentAndMediaView
{
    [self.commentAndMediaView resetView];
    self.commentAndMediaView.hasMedia = NO;
    self.commentAndMediaView.mediaThumbnailView.image = nil;
    self.commentAndMediaView.mediaThumbnailView.hidden = YES;
    
    __weak typeof(self) welf = self;
    self.commentAndMediaView.onMediaTapped = ^(void)
    {
        [welf tappedOnMedia];
    };
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.hasMedia = NO;
    self.onUserProfileTapped = nil;
    self.commentersAvatarImageView.image = nil;
    
    [self prepareContentAndMediaView];
}

#pragma mark - Target/Action

- (void)tappedOnMedia
{
    if ((self.onMediaTapped != nil) && (self.mediaURL != nil))
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

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.commentersUsernameLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        self.commentersUsernameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.timestampLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.realtimeCommentLocationLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
        self.commentAndMediaView.textFont = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    }
}

- (void)setComment:(VComment *)comment
{
    _comment = comment;
    
    self.mediaAssetOrientation = comment.assetOrientation;
    
    self.commentBody = comment.text;
    self.commenterName = comment.user.name;
    self.URLForCommenterAvatar = [NSURL URLWithString:comment.user.pictureUrl];
    self.timestampText = [comment.postedAt timeSince];
    
    if ((comment.realtime != nil) && (comment.realtime.floatValue >= 0))
    {
        self.realTimeCommentText = [[VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:@""
                                                                                            andPostedTime:comment.realtime
                                                                                    withDependencyManager:self.dependencyManager] string];
    }
    else
    {
        self.realTimeCommentText = @"";
    }
    self.hasMedia = comment.hasMedia;
    if (comment.hasMedia)
    {
        self.mediaPreviewURL = comment.previewImageURL;
        self.mediaIsVideo = [comment.mediaUrl v_hasVideoExtension];
    }
    
    self.commentCellUtilitiesController = [[VCommentCellUtilitesController alloc] initWithComment:self.comment
                                                                                         cellView:self
                                                                                         delegate:self];
    self.swipeViewController.cellDelegate = self.commentCellUtilitiesController;
}

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
        [self.commentAndMediaView.mediaThumbnailView sd_setImageWithURL:url
                                                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
        {
            if (error != nil)
            {
                return;
            }
            
            /**
             If the assetOrientation property was set, it was done so in a temporary comment
             after the comment was posted and before it could be reloaded from the server.
             In those cases, the rotation of the preview image will be off and requires adjustment
             */
            if ( self.mediaAssetOrientation != nil )
            {
                UIDeviceOrientation orientation = (UIDeviceOrientation)self.mediaAssetOrientation.integerValue;
                image = [image imageRotatedByDegrees:[AVAsset rotationAdjustmentForOrientation:orientation]];
            }
            
            [imageView setImage:image];
            [UIView animateWithDuration:kImagePreviewLoadedAnimationDuration animations:^
            {
                imageView.alpha = 1.0f;
            }];
            [imageCache setObject:image forKey:keyString];
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
    [self.commentAndMediaView.textView setupWithDatabaseFormattedText:_commentBody
                                                        tagAttributes:self.tagStringAttributes
                                                    defaultAttributes:self.defaultStringAttributes
                                                    andTagTapDelegate:nil];
}

- (void)setCommenterName:(NSString *)commenterName
{
    _commenterName = [commenterName copy];
    self.commentersUsernameLabel.text = commenterName;
}

- (void)setURLForCommenterAvatar:(NSURL *)URLForCommenterAvatar
{
    _URLForCommenterAvatar = [URLForCommenterAvatar copy];

    [self.commentersAvatarImageView sd_setImageWithURL:URLForCommenterAvatar
                                      placeholderImage:self.commentersAvatarImageView.image];

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

- (NSURL *)mediaURL
{
    return [NSURL URLWithString:self.comment.mediaUrl];
}

#pragma mark - lazy loading of string attributes

- (NSDictionary *)tagStringAttributes
{
    if ( _tagStringAttributes != nil )
    {
        return _tagStringAttributes;
    }
    
    NSMutableDictionary *tagStringAttributes = [[NSMutableDictionary alloc] initWithDictionary:self.defaultStringAttributes];
    tagStringAttributes[NSForegroundColorAttributeName] = [self.dependencyManager colorForKey:[VTagStringFormatter defaultDependencyManagerTagColorKey]];
    _tagStringAttributes = tagStringAttributes;
    return _tagStringAttributes;
}

- (NSDictionary *)defaultStringAttributes
{
    if ( _defaultStringAttributes != nil )
    {
        return _defaultStringAttributes;
    }
    
    _defaultStringAttributes = [VCommentTextAndMediaView attributesForTextWithFont:self.commentAndMediaView.textFont];
    return _defaultStringAttributes;
}

@end
