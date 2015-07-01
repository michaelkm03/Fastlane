//
//  VCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCreationTypes.h"
#import "VHasManagedDependencies.h"

@class VCreationFlowController;
@class VDependencyManager;

extern NSString * const VCreationFLowCaptureScreenKey;

/**
 *  A delegate for responding to events of the creation flow controller.
 */
@protocol VCreationFlowControllerDelegate <NSObject>

@required

/**
 *  Notifies the delegate that the workspaceflow is complete and ready to be dismissed.
 *
 *  @param workspaceFlowController The creationFlowController that just finished.
 *  @param previewImage            A preview image representing the just created content.
 *  @param capturedMediaURL        An NSURL of the location of the rendered content.
 */
- (void)creationFLowController:(VCreationFlowController *)creationFlowController
      finishedWithPreviewImage:(UIImage *)previewImage
              capturedMediaURL:(NSURL *)capturedMediaURL;

@optional

/**
 *  Notifies the delgate of a cancel. Presenters should dismiss the creationFlowController here.
 *  If not implemented the creation flow controller will dismiss itself.
 *
 *  ATTENTION: DO not modify this UINavigationController's delgate.
 */
- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController;

@end

@interface VCreationFlowController : UINavigationController <VHasManagedDependencies>

/**
 *  Use this method to get an appropriate CreationFLowController for the passed in type.
 */
+ (instancetype)newCreationFlowControllerWithCreationType:(VCreationType)type
                                     andDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The VCreationFlowControllerDelegate for this flow controller.
 */
@property (nonatomic, weak) id <VCreationFlowControllerDelegate> creationFlowDelegate;

@end
