//
//  VImageSearchViewController.h
//  victorious
//
//  Created by Josh Hinman on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VImageSearchDataSource.h"

@class VDependencyManager;

typedef void (^VMediaCaptureCompletion)(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL);

/**
 Displays an interface for searching and downloading images online.
 */
@interface VImageSearchViewController : UIViewController

/**
 Will be called when the user has either selected an image or asked to cancel
 */
@property (nonatomic, copy) VMediaCaptureCompletion imageSelectionHandler;

/**
 Setting this will trigger a search. If the user enters their own search term, it will be stored in this property.
 */
@property (nonatomic, copy) NSString *searchTerm;

+ (instancetype)newImageSearchViewControllerWithDependencyManager:(VDependencyManager *)dependencyMananger;

@end
