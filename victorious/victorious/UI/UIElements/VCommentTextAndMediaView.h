//
//  VCommentTextAndMediaView.h
//  victorious
//
//  Created by Josh Hinman on 8/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This view is used inside the comment and messaging views
 to display comment text and any media that might
 be attached to the comment.
 */
@interface VCommentTextAndMediaView : UIView

@property (nonatomic, copy)           NSString     *text;
@property (nonatomic, weak, readonly) UIImageView  *mediaThumbnailView;
@property (nonatomic, weak, readonly) UIImageView  *playIcon; ///< Default is hidden. Show for video content
@property (nonatomic, copy)           void        (^onMediaTapped)(); ///< Called when the user taps the media icon

/**
 Returns the ideal height for instances of this view
 given specific width, text, and whether or not
 we need room for a media thumbnail.
 */
+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width text:(NSString *)text withMedia:(BOOL)hasMedia;

/**
 Returns a block that, when invoked, presents the standard media player, 
 playing the given mediaURL, from the given view controller.
 
 @return a block that can be assigned to the onMediaTapped property
 */
- (void(^)(void))standardMediaTapHandlerWithMediaURL:(NSURL *)mediaURL presentingViewController:(UIViewController *)presentingViewController;

/**
 Removes common customizations (text, images, etc) and returns this view to a pristine state.
 */
- (void)resetView;

@end
