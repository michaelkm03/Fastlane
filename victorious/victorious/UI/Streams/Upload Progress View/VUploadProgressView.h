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
    VUploadProgressViewStateFailed,
    VUploadProgressViewStateFinalizing,
    VUploadProgressViewStateFinished,
};

@protocol VUploadProgressViewDelegate <NSObject>
@optional

/**
 Notifies the delegate that the accessory button was tapped
 */
- (void)accessoryButtonTappedInUploadProgressView:(VUploadProgressView *)uploadProgressView;

@end

@interface VUploadProgressView : UIView

@property (nonatomic, strong) VUploadTaskInformation *uploadTask; ///< The upload task whose progress this view is displaying
@property (nonatomic) VUploadProgressViewState state; ///< The state of the upload
@property (nonatomic, weak) id<VUploadProgressViewDelegate> delegate; ///< The view's delegate

/**
 Creates a new instance of VUploadProgressView by loading it from a nib.
 */
+ (instancetype)uploadProgressViewFromNib;

@end
