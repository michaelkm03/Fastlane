//
//  VCommentTextAndMediaView.m
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextAndMediaView.h"
#import "VLightboxTransitioningDelegate.h"
#import "VThemeManager.h"
#import "VVideoLightboxViewController.h"
#import "VTagSensitiveTextView.h"
#import "UIView+AutoLayout.h"
#import "VComment+Fetcher.h"
#import "victorious-Swift.h"

@interface VTextAndMediaView ()

@property (nonatomic, strong) NSArray *mediaViewVerticalConstraints;

@end

@implementation VTextAndMediaView

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
    
    UITextView *textView = self.textView;
    
    [self.textView setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(textView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[textView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(textView)]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.preferredMaxLayoutWidth)
    {
        [super layoutSubviews]; // two-pass layout because we're changing the preferredMaxLayoutWidth, above, which means constraints need to be re-calculated.
    }
}

- (void)setMediaAttachmentView:(MediaAttachmentView *)mediaAttachmentView
{
    if (_mediaAttachmentView == mediaAttachmentView)
    {
        return;
    }
    
    _mediaAttachmentView = mediaAttachmentView;
    if (mediaAttachmentView != nil)
    {
        _mediaAttachmentView.translatesAutoresizingMaskIntoConstraints = NO;
        __weak VTextAndMediaView *wSelf = self;
        [_mediaAttachmentView setRespondToButton:^(UIImage *previewImage) {
            __strong VTextAndMediaView *sSelf = wSelf;
            [sSelf mediaTappedWithPreviewImage:previewImage];
        }];
        [self addSubview:_mediaAttachmentView];
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaAttachmentView]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(_mediaAttachmentView)]];
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.mediaAttachmentView.dependencyManager = dependencyManager;
}

- (void)updateConstraints
{
    if (self.mediaAttachmentView != nil)
    {
        [self removeConstraints:self.mediaViewVerticalConstraints];
        
        if (self.textView.attributedText.length > 0 || self.textView.text.length > 0)
        {
            self.mediaViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_textView]-space-[_mediaAttachmentView]|"
                                                                                        options:0
                                                                                        metrics:@{@"space" : @(kSpacingBetweenTextAndMedia)}
                                                                                          views:NSDictionaryOfVariableBindings(_textView, _mediaAttachmentView)];
            
        }
        else
        {
            self.mediaViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mediaAttachmentView]|"
                                                                                        options:0
                                                                                        metrics:nil
                                                                                          views:NSDictionaryOfVariableBindings(_mediaAttachmentView)];
        }
        
        [self addConstraints:self.mediaViewVerticalConstraints];
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
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:(text ?: @"") attributes: self.textFont ? [[self class] attributesForTextWithFont:self.textFont] :[[self class] attributesForText]];
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

- (void)setFocusType:(VFocusType)focusType
{
    _focusType = focusType;
    self.mediaAttachmentView.focusType = focusType;
}

#pragma mark - Actions

- (void)mediaTappedWithPreviewImage:(UIImage *)previewImage
{
    if (self.onMediaTapped != nil)
    {
        self.onMediaTapped(previewImage);
    }
    else if ([self.mediaTapDelegate respondsToSelector:@selector(tappedMediaWithURL:previewImage:fromView:)])
    {
        [self.mediaTapDelegate tappedMediaWithURL:self.mediaURLForLightbox previewImage:previewImage fromView:self.mediaAttachmentView];
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

- (void)resetView
{
    self.text = @"";
    self.onMediaTapped = nil;
    [self.mediaAttachmentView prepareForReuse];
}

@end
