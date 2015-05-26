//
//  VUploadProgressView.h
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUploadProgressView, VUploadTaskInformation;

typedef NS_ENUM(NSInteger, VUploadProgressViewState)
{
    VUploadProgressViewStateInProgress,
    VUploadProgressViewStateCanceling,
    VUploadProgressViewStateFailed,
    VUploadProgressViewStateFinalizing,
    VUploadProgressViewStateFinished,
};

@protocol VUploadProgressViewDelegate <NSObject>
@optional

/**
 Notifies the delegate that the accessory button was tapped.
 */
- (void)accessoryButtonTappedInUploadProgressView:(VUploadProgressView *)uploadProgressView;

/**
 Notifies the delegate thtat the second accessory button was tapped.
 */
- (void)alternateAccessoryButtonTappedInUploadProgressView:(VUploadProgressView *)uploadProgressView;

@end

@interface VUploadProgressView : UIView

@property (nonatomic, strong) VUploadTaskInformation *uploadTask; ///< The upload task whose progress this view is displaying
@property (nonatomic) VUploadProgressViewState state; ///< The state of the upload
@property (nonatomic, weak) id<VUploadProgressViewDelegate> delegate; ///< The view's delegate

/**
 Creates a new instance of VUploadProgressView by loading it from a nib.
 */
+ (instancetype)uploadProgressViewFromNib;

/**
 Updates the progress bar, with optional animation
 */
- (void)setProgress:(CGFloat)progressPercent animated:(BOOL)animated;

@end
