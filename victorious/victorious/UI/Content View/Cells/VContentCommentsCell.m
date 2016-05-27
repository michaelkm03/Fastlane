//
//  VContentCommentsCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentsCell.h"


// Subviews
#import "VDefaultProfileButton.h"
#import "VCommentTextAndMediaView.h"

// Dependency Manager
#import "VDependencyManager.h"

// Formatting
#import "UIImage+ImageCreation.h"
#import "AVAsset+Orientation.h"
#import "VComment+Fetcher.h"
#import "NSURL+MediaType.h"
#import "UIView+AutoLayout.h"
#import "VTagStringFormatter.h"

#import "VTagSensitiveTextView.h"

#import "VSequence+Fetcher.h"
#import "VSequencePermissions.h"
#import "VComment+Fetcher.h"

#import "victorious-Swift.h"

@import SDWebImage;

static const UIEdgeInsets kTextInsets = { 38.0f, 56.0f, 20.0f, 55.0f };

static NSCache *_sharedImageCache = nil;

@interface VContentCommentsCell ()

@property (weak, nonatomic) IBOutlet VDefaultProfileButton *commentersAvatarButton;
@property (weak, nonatomic) IBOutlet UILabel *commentersUsernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIImageView *seperatorImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clockIconImageView;

@property (nonatomic, strong) NSNumber *mediaAssetOrientation;
@property (nonatomic, copy) NSString *commenterName;
@property (nonatomic, copy) NSString *timestampText;
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
                    comment:(VComment *)comment
                   hasMedia:(BOOL)hasMedia
          dependencyManager:(VDependencyManager *)dependencyManager
{
    CGFloat textHeight = [VCommentTextAndMediaView estimatedHeightWithWidth:(width - kTextInsets.left - kTextInsets.right)
                                                                    comment:comment
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
    
    self.commentAndMediaView.preferredMaxLayoutWidth = CGRectGetWidth(self.commentAndMediaView.frame);

    [self prepareContentAndMediaView];
    
    self.commentersAvatarButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self setupSwipeView];
    [self.contentView v_addFitToParentConstraintsToSubview:self.swipeViewController.view];
}

- (void)prepareContentAndMediaView
{
    [self.commentAndMediaView resetView];
}

#pragma mark - UICollectionReusableView

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.hasMedia = NO;
    self.onUserProfileTapped = nil;
    
    [self prepareContentAndMediaView];
}

#pragma mark - Target/Action

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
        self.commentAndMediaView.textFont = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        self.commentersAvatarButton.dependencyManager = dependencyManager;
    }
}

- (void)setComment:(VComment *)comment
{
    _comment = comment;
    
    self.mediaAssetOrientation = comment.assetOrientation;
    
    self.commentBody = comment.text;
    self.commenterName = comment.user.name;
    self.commentersAvatarButton.user = comment.user;
    self.timestampText = [comment.postedAt stringDescribingTimeIntervalSinceNow];
    self.mediaIsVideo = comment.commentMediaType == VCommentMediaTypeVideo;
    self.hasMedia = comment.commentMediaType != VCommentMediaTypeNoMedia;
    
    [self.commentAndMediaView setComment:comment];
    [self.commentAndMediaView setDependencyManager:self.dependencyManager];

    self.commentCellUtilitiesController = [[VCommentCellUtilitiesController alloc] initWithComment:self.comment
                                                                                          cellView:self
                                                                                          delegate:self
                                                                                       permissions:self.sequencePermissions];
    self.swipeViewController.cellDelegate = self.commentCellUtilitiesController;
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

- (void)setTimestampText:(NSString *)timestampText
{
    _timestampText = [timestampText copy];
    self.timestampLabel.text = timestampText;
}

- (NSURL *)mediaURL
{
    return [self.comment properMediaURLGivenContentType];
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
    
    _defaultStringAttributes = [VTextAndMediaView attributesForTextWithFont:self.commentAndMediaView.textFont];
    return _defaultStringAttributes;
}

#pragma mark - Focus

@dynamic focusType;

- (void)setFocusType:(VFocusType)focusType
{
    self.commentAndMediaView.focusType = focusType;
}

- (VFocusType)focusType
{
    return self.commentAndMediaView.focusType;
}

- (CGRect)contentArea
{
    return [self convertRect:self.commentAndMediaView.frame toView:self];
}

@end
