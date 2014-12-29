//
//  VPublishViewController.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

/**
 *  A ViewController for publshing content.
 */
@interface VPublishViewController : UIViewController <VHasManagedDependancies>

@property (nonatomic, strong) UIImage *previewImage; ///< An image for any previewing
@property (nonatomic, strong) NSURL *mediaToUploadURL; ///< The URL of the media that will be uploaded

@property (nonatomic, copy) void (^completion)(BOOL published); ///< Called upon completion, YES indicates successful publish

@property (nonatomic, copy, readonly) void (^animateInBlock)(void); ///< PublishViewController wants this to be called by animators

@end
