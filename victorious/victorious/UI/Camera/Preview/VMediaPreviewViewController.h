//
//  VMediaPreviewViewController.h
//  victorious
//
//  Created by Josh Hinman on 4/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^VMediaCaptureCompletion)(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL);

/**
 Abstract base class for view controllers 
 that show a preview of captured media.
 */
@interface VMediaPreviewViewController : UIViewController

@property (nonatomic, strong)        NSURL  *mediaURL;
@property (nonatomic, weak) IBOutlet UIView *previewImageSuperview;
@property (nonatomic, weak) IBOutlet UIView *bottomButtonSuperview;
@property (nonatomic, weak, readonly) IBOutlet UIButton     *nextButton;
@property (nonatomic, weak, readonly) IBOutlet UIButton    *doneButton;
@property (nonatomic) BOOL didSelectAssetFromLibrary;

/**
 A completion block to call when the user has finished previewing media
 */
@property (nonatomic, copy) VMediaCaptureCompletion completionBlock;

/**
 Create a new preview view controller for the given media.
 */
+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL;

/**
 Designated initializer to give subclasses a good place to 
 do their initialization with the media URL (which is 
 readonly and thus can't change later). If you're not a
 subclass, please use the class constructor instead.
 */
- (instancetype)initWithMediaURL:(NSURL *)mediaURL;

/**
 This method should not be called directly; subclassses override
 it to provide a thumbnail image that will be returned to the
 VMediaCaptureCompletion block as the previewImage argument.
 */
- (UIImage *)previewImage;

/**
 Subclasses can override this if they need to make changes to the
 mediaURL before it gets passed on to the completion block. No
 need to call super.
 */
- (void)willComplete;

/**
 Subclasses should call this method when the user taps the media preview 
 view. If subclasses add no subviews to previewImageSuperview, or they
 add only subviews for which userInteractionEnabled is NO, then there is
 no need to call this method.
 */
- (IBAction)mediaPreviewTapped:(id)sender;

@end
