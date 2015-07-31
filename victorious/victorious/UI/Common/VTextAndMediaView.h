//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VDependencyManager.h"
#import "victorious-Swift.h"

static const CGFloat kSpacingBetweenTextAndMedia = 4.0f;

@protocol VCommentMediaTapDelegate <NSObject>

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view;

@end

@class VTagSensitiveTextView;


/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment or message.
 */
@interface VTextAndMediaView : UIView

@property (nonatomic) CGFloat preferredMaxLayoutWidth; ///< Used when calculating intrinsicContentSize
@property (nonatomic, copy) void (^onMediaTapped)(UIImage *previewImage); ///< Called when the user taps the media icon

@property (nonatomic, weak) id<VCommentMediaTapDelegate> mediaTapDelegate;

@property (nonatomic) UIFont *textFont;
@property (nonatomic, strong) VTagSensitiveTextView *textView;

@property (nonatomic, assign) BOOL inFocus;

@property (nonatomic, strong) MediaAttachmentView *mediaAttachmentView;

@property (nonatomic, strong) NSURL *mediaURLForLightbox;

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;

// For calculating intrinsic content size
@property (nonatomic, assign) BOOL hasMedia;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 Removes common customizations (text, images, etc) and returns this view to a pristine state.
 */
- (void)resetView;

+ (NSDictionary *)attributesForTextWithFont:(UIFont *)font;
+ (NSDictionary *)attributesForText;

@end
