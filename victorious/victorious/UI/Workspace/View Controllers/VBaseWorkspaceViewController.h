//
//  VBaseWorkspaceViewController.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VToolController.h"

@class VToolController, VCanvasView;

typedef void (^VWorkspaceCompletion)(BOOL finished, UIImage *previewImage, NSURL *renderedMediaURL);

/**
 
 VBaseWorkspaceViewController is the container for all of the major components of editing. It's primary responsibility is to maintain the view hierarchy of three key areas:
 
 The Canvas View -The canvas view is the area where a user can preview their edits to their currently selected item. It has an ImageView which sits inside of a scrollView. The scrollView is used as an artboard and slice tool (the bounds of the scrollview represent the currently selected slice for exporting).
 The inspector View - The inspector view is where tools can add additional UI such as a picker, slider, etc.
 A toolbar - Representing the currently selected top level tool. For images these are: Text, Filters, and crop.
 
 */
@interface VBaseWorkspaceViewController : UIViewController <VHasManagedDependencies, VToolControllerDelegate>

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

@property (nonatomic, copy) NSString *continueText;
@property (nonatomic, copy) VWorkspaceCompletion completionBlock; ///< Called upon completion. PreviewImage and RenderedMediaURL will be nil if unsuccessful.

@property (nonatomic, strong) VToolController *toolController; ///< The toolController

@property (nonatomic, assign) BOOL shouldConfirmCancels; ///< The workspace will show a "discard" action sheet before calling it's completion block

@property (nonatomic, weak, readonly) VCanvasView *canvasView;

/**
 *  The initial edit state. (since dependency injection doesn't inherit from parent to child).
 */
@property (nonatomic, strong) NSNumber *initalEditState;

@property (nonatomic, assign) BOOL showCloseButton;
@property (nonatomic, assign) BOOL continueButtonEnabled;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *continueButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *backButton;

@property (nonatomic, assign) BOOL disablesInpectorOnKeyboardAppearance;
@property (nonatomic, assign) BOOL disablesNavigationItemsOnKeyboardAppearance;
@property (nonatomic, assign) BOOL adjustsCanvasViewFrameOnKeyboardAppearance;

@property (nonatomic, assign) BOOL shouldHideBottomBar;

- (void)callCompletionWithSuccess:(BOOL)success
                     previewImage:(UIImage *)previewImage
                 renderedMediaURL:(NSURL *)renderedMediaURL;

- (void)bringTopChromeOutOfView;
- (void)bringBottomChromeOutOfView;
- (void)bringChromeIntoView;

@end
