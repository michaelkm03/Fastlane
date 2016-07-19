//
//  VCreationFlowController.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCreationFlowTypes.h"
#import "VHasManagedDependencies.h"
#import "VPublishParameters.h"

@class VCreationFlowController;
@class VDependencyManager;
@class VAlternateCaptureOption;

extern NSString * const VCreationFLowCaptureScreenKey;

/*
 *  The media type that the CreationFlowController contains.
 */
typedef NS_ENUM (NSUInteger, MediaType) {
    MediaTypeImage,
    MediaTypeVideo,
    MediaTypeUnknown,
};

typedef NS_ENUM(NSInteger, VCreationFlowSource)
{
    VCreationFlowSourceLibrary,
    VCreationFlowSourceCamera,
    VCreationFlowSourceSearch,
};

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
- (void)creationFlowController:(VCreationFlowController *)creationFlowController
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

/**
 *  Asks the delegate whether or not the creation flow should show a publish screen for
 *  creating a new sequence. If this is not implemented the creation flow will show
 *  a publish screen.
 */
- (BOOL)shouldShowPublishScreenForFlowController;

@end

@interface VCreationFlowController : UINavigationController <VHasManagedDependencies, UIViewControllerTransitioningDelegate>

/**
 *  The VCreationFlowControllerDelegate for this flow controller.
 */
@property (nonatomic, weak) id <VCreationFlowControllerDelegate> creationFlowDelegate;

/**
 *  Publish parameters for the creationFlowController. Note this may not be actually used to publish,
 *  but consumers can leverage this to be informed of what happed in the creation flow.
 */
@property (nonatomic, readonly) VPublishParameters *publishParameters;

/**
 *  Convenience for subclasses to add a templated close button to their viewControllers.
 */
- (void)addCloseButtonToViewController:(UIViewController *)viewController;

/**
 *  Use this to determine the next text of the workspace.
 */
- (BOOL)shouldShowPublishText;

/**
 *  The navigation controller that manages the creation flow.
 *  Defaults to self.
 */
- (UINavigationController *)rootFlowController;

/**
 *  Returns MediaTypeUnknown. Subclasses should override
 */
- (MediaType)mediaType;

@property (nonatomic, strong, readonly) VAlternateCaptureOption *cameraCaptureOption;

@property (nonatomic, strong, readonly) VAlternateCaptureOption *searchCaptureOption;

// Tracking Properties
@property (nonatomic, assign) VCreationFlowSource source;

@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end
