//
//  VCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCreationTypes.h"
#import "VHasManagedDependencies.h"

@class VCreationFlowController;

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
 */
- (void)creationFlowControllerDidCancel:(VCreationFlowController *)creationFlowController;

@end

/**
 *  Use this key to inject the appropriate VCreationType into the CreationFlowController. 
 *  Wrap the enum value in an NSNumber like so: ```VCreationTypeImage```.
 */
extern NSString * const VCreationFlowControllerCreationTypeKey;

@interface VCreationFlowController : UINavigationController <VHasManagedDependencies>

@property (nonatomic, weak) id <VCreationFlowControllerDelegate> creationFlowDelegate;

@end
