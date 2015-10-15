//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VDependencyManager.h"
#import "VFocusable.h"

NS_ASSUME_NONNULL_BEGIN

static const CGFloat kSpacingBetweenTextAndMedia = 4.0f;

@protocol VCommentMediaTapDelegate <NSObject>

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view;

@end

@class VTagSensitiveTextView;
@class MediaAttachmentView;

/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment or message.
 */
@interface VTextAndMediaView : UIView

@property (nonatomic) CGFloat preferredMaxLayoutWidth; ///< Used when calculating intrinsicContentSize
@property (nonatomic, copy, nullable) void (^onMediaTapped)(UIImage *_Nullable previewImage); ///< Called when the user taps the media icon

@property (nonatomic, weak, nullable) id<VCommentMediaTapDelegate> mediaTapDelegate;

@property (nonatomic, nullable) UIFont *textFont;
@property (nonatomic, strong, nullable) VTagSensitiveTextView *textView;

@property (nonatomic, assign) VFocusType focusType;

@property (nonatomic, strong, nullable) MediaAttachmentView *mediaAttachmentView;

@property (nonatomic, strong, nullable) NSURL *mediaURLForLightbox;

@property (nonatomic, strong, nullable) NSString *text;
@property (nonatomic, strong, nullable) NSAttributedString *attributedText;

// For calculating intrinsic content size
@property (nonatomic, assign) BOOL hasMedia;

@property (nonatomic, strong, nullable) VDependencyManager *dependencyManager;

/**
 Removes common customizations (text, images, etc) and returns this view to a pristine state.
 */
- (void)resetView;

+ (NSDictionary *)attributesForTextWithFont:(UIFont *)font;
+ (NSDictionary *)attributesForText;

@end

NS_ASSUME_NONNULL_END
