//
//  VUploadProgressViewController.h
//  victorious
//
//  Created by Josh Hinman on 10/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat VUploadProgressViewControllerIdealHeight; ///< The ideal height for instances of VUploadProgressViewController

@class VUploadManager, VUploadProgressViewController;

@protocol VUploadProgressViewControllerDelegate <NSObject>
@optional

/**
 Notifies the delegate that the number of uploads being displayed has changed
 */
- (void)uploadProgressViewController:(VUploadProgressViewController *)upvc isNowDisplayingThisManyUploads:(NSInteger)uploadCount;

@end

@interface VUploadProgressViewController : UIViewController

@property (nonatomic, readonly) VUploadManager *uploadManager; ///< The upload manager whose uploads we are displaying
@property (nonatomic, readonly) NSInteger numberOfUploads; ///< The number of uploads being displayed by this view
@property (nonatomic, weak) id<VUploadProgressViewControllerDelegate> delegate; ///< The progress view controller's delegate

/**
 Returns a new instance of VUploadProgressViewController
 
 @param uploadManager the upload manager whose uploads will be displayed
 */
+ (instancetype)viewControllerForUploadManager:(VUploadManager *)uploadManager;

@end
