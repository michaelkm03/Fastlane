//
//  VImageSearchViewController.h
//  victorious
//
//  Created by Josh Hinman on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageSearchDataSource.h"
#import "VMediaPreviewViewController.h"

#import <UIKit/UIKit.h>

/**
 Displays an interface for searching and downloading images online.
 */
@interface VImageSearchViewController : UIViewController <UICollectionViewDelegate, UITextFieldDelegate, VImageSearchDataDelegate>

@property (nonatomic, copy) VMediaCaptureCompletion completionBlock; ///< Will be called when the user has either selected an image or asked to cancel

+ (instancetype)newImageSearchViewController;

@end
