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

@property (nonatomic, readonly)      NSURL  *mediaURL;
@property (nonatomic, weak) IBOutlet UIView *previewImageSuperview;

/**
 A completion block to call when the user has finished previewing media
 */
@property (nonatomic, copy) VMediaCaptureCompletion completionBlock;

+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL;

/**
 This method should not be called directly; subclassses override
 it to provide a thumbnail image that will be returned to the
 VMediaCaptureCompletion block as the previewImage argument.
 */
- (UIImage *)previewImage;

/**
 Subclasses should call this method when the user taps the media preview 
 view. If subclasses add no subviews to previewImageSuperview, or they
 add only subviews for which userInteractionEnabled is NO, then there is
 no need to call this method.
 */
- (IBAction)mediaPreviewTapped:(id)sender;

@end
