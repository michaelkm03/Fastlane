//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VVideoView.h"
#import "victorious-Swift.h"

static const CGFloat kSpacingBetweenTextAndMedia = 4.0f;

@protocol VCommentMediaTapDelegate <NSObject>

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view;

@end

@class VTagSensitiveTextView;


/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment.
 */
@interface VTextAndMediaView : UIView

@property (nonatomic, copy)           NSString           *text;
@property (nonatomic, copy)           NSAttributedString *attributedText;
@property (nonatomic, weak, readonly) UIImageView        *mediaThumbnailView;
@property (nonatomic, weak, readonly) UIImageView        *playIcon; ///< Default is hidden. Show for video content
@property (nonatomic)                 CGFloat            preferredMaxLayoutWidth; ///< Used when calculating intrinsicContentSize
@property (nonatomic)                 BOOL               hasMedia;                ///< If YES, the size of the media thumbnail is included in the intrinsicContentSize
@property (nonatomic, copy)           void               (^onMediaTapped)(); ///< Called when the user taps the media icon

//@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, weak) id<VCommentMediaTapDelegate> mediaTapDelegate;

@property (nonatomic) UIFont *textFont;
@property (nonatomic, strong) VTagSensitiveTextView *textView;
//@property (nonatomic, strong) NSURL *autoplayURL;

@property (nonatomic, strong, readonly) VVideoView *videoView;
@property (nonatomic, assign) BOOL inFocus;

@property (nonatomic, strong, readonly) MediaAttachmentView *mediaAttachmentView;

/**
 Removes common customizations (text, images, etc) and returns this view to a pristine state.
 */
- (void)resetView;

+ (NSDictionary *)attributesForTextWithFont:(UIFont *)font;
+ (NSDictionary *)attributesForText;

@end
