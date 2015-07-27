//
//  VCommentTextAndMediaView.m
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCommentTextAndMediaView.h"
#import "VLightboxTransitioningDelegate.h"
#import "VThemeManager.h"
#import "VVideoLightboxViewController.h"
#import "VTagSensitiveTextView.h"
#import "UIView+AutoLayout.h"
#import "VComment+Fetcher.h"

static const CGFloat kSpacingBetweenTextAndMedia = 4.0f;

@interface VCommentTextAndMediaView ()

@property (nonatomic) BOOL addedConstraints;
@property (nonatomic, weak) UIButton *mediaButton;
@property (nonatomic, readwrite) UIImageView *mediaThumbnailView;
@property (nonatomic, readwrite) UIImageView *playIcon;
@property (nonatomic, strong) UIView *mediaBackground;
@property (nonatomic, strong) VVideoView *videoView;

@end

@implementation VCommentTextAndMediaView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.textView = [[VTagSensitiveTextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.selectable = YES;
    self.textView.editable = NO;
    self.textView.scrollEnabled = NO;
    self.textView.userInteractionEnabled = YES;
    self.textView.textContainerInset = UIEdgeInsetsMake( 4.0, 0.0, 4.0, 0.0 );
    self.textView.textContainer.lineFragmentPadding = 0.0f;
    self.textView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.textView.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.textView.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    [self addSubview:self.textView];
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    background.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:background];
    self.mediaBackground = background;
    
    UIImageView *mediaThumbnailView = [[UIImageView alloc] init];
    mediaThumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
    mediaThumbnailView.clipsToBounds = YES;
    mediaThumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    mediaThumbnailView.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    [self addSubview:mediaThumbnailView];
    self.mediaThumbnailView = mediaThumbnailView;
    
    UIImageView *playIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PlayIcon"]];
    playIcon.translatesAutoresizingMaskIntoConstraints = NO;
    playIcon.hidden = YES;
    [self addSubview:playIcon];
    self.playIcon = playIcon;
    
    UIButton *mediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    mediaButton.translatesAutoresizingMaskIntoConstraints = NO;
    mediaButton.adjustsImageWhenHighlighted = NO;
    mediaButton.clipsToBounds = YES;
    [mediaButton addTarget:self action:@selector(mediaTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:mediaButton];
    self.mediaButton = mediaButton;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.preferredMaxLayoutWidth)
    {
        [super layoutSubviews]; // two-pass layout because we're changing the preferredMaxLayoutWidth, above, which means constraints need to be re-calculated.
    }
}

- (void)updateConstraints
{
    UITextView *textView = self.textView;
    UIButton *mediaButton = self.mediaButton;
    UIImageView *mediaThumbnailView = self.mediaThumbnailView;
    UIImageView *playIcon = self.playIcon;
    UIView *background = self.mediaBackground;
    
    if (!self.addedConstraints)
    {
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(textView)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[mediaButton]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(mediaButton)]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mediaButton]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(mediaButton)]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaButton
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaButton
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaButton
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaButton
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaButton
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaButton
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:playIcon
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:playIcon
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:background
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:background
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:background
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mediaThumbnailView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:background
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
        
        self.addedConstraints = YES;
    }
    
    [super updateConstraints];
}

- (CGSize)intrinsicContentSize
{
    CGSize textViewSize = [self.textView sizeThatFits:CGSizeMake( self.preferredMaxLayoutWidth, CGFLOAT_MAX)];
    
    if (self.hasMedia)
    {
        CGFloat mediaThumbnailSize = MAX(textViewSize.width, self.preferredMaxLayoutWidth); // CGFloat instead of CGSize because it's a square thumbnail
        return CGSizeMake(MAX(textViewSize.width, mediaThumbnailSize), textViewSize.height + kSpacingBetweenTextAndMedia + mediaThumbnailSize);
    }
    else
    {
        return textViewSize;
    }
}

#pragma mark - Properties

- (void)setText:(NSString *)text
{
    _text = [text copy];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:(text ?: @"") attributes: self.textFont ? [[self class] attributesForTextWithFont:self.textFont] :[[self class] attributesForText]];;
    self.textView.attributedText = attributedText;
    [self invalidateIntrinsicContentSize];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    _attributedText = [attributedText copy];
    self.textView.attributedText = _attributedText;
    [self invalidateIntrinsicContentSize];
}

- (void)setPreferredMaxLayoutWidth:(CGFloat)preferredMaxLayoutWidth
{
    _preferredMaxLayoutWidth = preferredMaxLayoutWidth;
    [self invalidateIntrinsicContentSize];
}

- (void)setHasMedia:(BOOL)hasMedia
{
    _hasMedia = hasMedia;
    self.mediaButton.hidden = !hasMedia;
    self.mediaBackground.hidden = !hasMedia;
    [self invalidateIntrinsicContentSize];
}

- (void)setMediaType:(VCommentMediaType)mediaType
{
    _mediaType = mediaType;
    switch (mediaType)
    {
        case VCommentMediaTypeVideo:
        {
            self.playIcon.hidden = NO;
            break;
        }
            
        case VCommentMediaTypeGIF:
        {
            if (self.videoView == nil)
            {
                self.videoView = [[VVideoView alloc] init];
                [self.mediaButton addSubview:self.videoView];
                [self.mediaButton v_addFitToParentConstraintsToSubview:self.videoView];
            }
            
            self.playIcon.hidden = YES;
            break;
        }
        
        case VCommentMediaTypeImage:
        default:
        {
            self.playIcon.hidden = YES;
            break;
        }
    }
}

- (void)setAutoplayURL:(NSURL *)autoplayURL
{
    if (_autoplayURL == autoplayURL || self.mediaType != VCommentMediaTypeGIF)
    {
        return;
    }
    
    _autoplayURL = autoplayURL;
    [self.videoView setItemURL:_autoplayURL loop:YES audioMuted:YES];
    self.videoView.hidden = NO;
}

- (void)setInFocus:(BOOL)inFocus
{
    _inFocus = inFocus;
    if (self.mediaType == VCommentMediaTypeGIF)
    {
        inFocus ? [self.videoView play] : [self.videoView pause];
    }
}

#pragma mark - Actions

- (void)mediaTapped:(UIButton *)sender
{
    if (self.onMediaTapped != nil)
    {
        self.onMediaTapped();
    }
    else if ([self.mediaTapDelegate respondsToSelector:@selector(tappedMediaWithURL:previewImage:fromView:)])
    {
        [self.mediaTapDelegate tappedMediaWithURL:self.mediaURL previewImage:self.mediaThumbnailView.image fromView:self.mediaThumbnailView];
    }
}

#pragma mark -

+ (NSDictionary *)attributesForTextWithFont:(UIFont *)font
{
    NSMutableDictionary *mutableAttributes = [[self attributesForText] mutableCopy];
    mutableAttributes[NSFontAttributeName] = font;
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

+ (NSDictionary *)attributesForText
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.minimumLineHeight = 20.0f;
    paragraphStyle.maximumLineHeight = 20.0f;

    return @{ NSFontAttributeName: [UIFont systemFontOfSize:17.0f],
              NSForegroundColorAttributeName: [UIColor colorWithRed:0.137f green:0.137f blue:0.137f alpha:1.0f],
              NSParagraphStyleAttributeName: paragraphStyle,
           };
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width
                               text:(NSString *)text
                          withMedia:(BOOL)hasMedia
{
    return [self estimatedHeightWithWidth:width
                                     text:text
                                withMedia:hasMedia
                                  andFont:nil];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width
                               text:(NSString *)text
                          withMedia:(BOOL)hasMedia
                            andFont:(UIFont *)font
{
    if (!text)
    {
        return 0;
    }
    
    __block CGRect boundingRect = CGRectZero;
    CGFloat mediaSpacing = 0.0f;
    if ( ![text isEqualToString:@""] )
    {
        NSDictionary *attributes = font != nil ? [self attributesForTextWithFont:font] : [self attributesForText];
        [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:text tagAttributes:attributes andDefaultAttributes:attributes toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
        {
            boundingRect = [displayFormattedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                                context:[[NSStringDrawingContext alloc] init]];
        }];
        mediaSpacing = kSpacingBetweenTextAndMedia;
    }
    CGFloat mediaSize = hasMedia ? width + mediaSpacing : 0.0f;
    return VCEIL(CGRectGetHeight(boundingRect)) + mediaSize;
}

- (void)resetView
{
    self.text = @"";
    self.mediaThumbnailView.hidden = NO;
    self.mediaThumbnailView.image = nil;
    self.hasMedia = NO;
    self.onMediaTapped = nil;
    self.playIcon.hidden = YES;
    self.videoView.hidden = YES;
    self.videoView.itemURL = nil;
    self.mediaURL = nil;
}

@end
