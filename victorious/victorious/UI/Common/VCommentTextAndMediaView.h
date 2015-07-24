//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VVideoView.h"

@protocol VCommentMediaTapDelegate <NSObject>

- (void)tappedMediaWithURL:(NSURL *)mediaURL previewImage:(UIImage *)image fromView:(UIView *)view;

@end

@class VTagSensitiveTextView;

/**
 A type of comment media
 */
typedef NS_ENUM(NSInteger, VCommentMediaViewType)
{
    VCommentMediaViewTypeImage,
    VCommentMediaViewTypeVideo,
    VCommentMediaViewTypeGIF,
};

/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment.
 */
@interface VCommentTextAndMediaView : UIView

@property (nonatomic, assign) VCommentMediaViewType mediaType;
@property (nonatomic, copy)           NSString           *text;
@property (nonatomic, copy)           NSAttributedString *attributedText;
@property (nonatomic, weak, readonly) UIImageView        *mediaThumbnailView;
@property (nonatomic, weak, readonly) UIImageView        *playIcon; ///< Default is hidden. Show for video content
@property (nonatomic)                 CGFloat            preferredMaxLayoutWidth; ///< Used when calculating intrinsicContentSize
@property (nonatomic)                 BOOL               hasMedia;                ///< If YES, the size of the media thumbnail is included in the intrinsicContentSize
@property (nonatomic, copy)           void               (^onMediaTapped)(); ///< Called when the user taps the media icon

@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, weak) id<VCommentMediaTapDelegate> mediaTapDelegate;

@property (nonatomic) UIFont *textFont;
@property (nonatomic, strong) VTagSensitiveTextView *textView;
@property (nonatomic, strong) NSURL *autoplayURL;

@property (nonatomic, strong, readonly) VVideoView *videoView;
@property (nonatomic, assign) BOOL inFocus;

/**
 Returns the ideal height for instances of this view
 given specific width, text, font, and whether or not
 we need room for a media thumbnail.
 */
+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia andFont:(UIFont *)font;

/**
Same as above but without a custom font.
 */+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia;

/**
 Removes common customizations (text, images, etc) and returns this view to a pristine state.
 */
- (void)resetView;

+ (NSDictionary *)attributesForTextWithFont:(UIFont *)font;
+ (NSDictionary *)attributesForText;

@end
