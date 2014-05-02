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

@property (nonatomic, readonly) NSURL *mediaURL;

/**
 A completion block to call when the user has finished previewing media
 */
@property (nonatomic, copy) VMediaCaptureCompletion completionBlock;

+ (VMediaPreviewViewController *)previewViewControllerForMediaAtURL:(NSURL *)mediaURL;

@end
