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

@property (nonatomic, copy) void (^completion)(BOOL published); ///< Called upon completion, YES indicates successful publish

@property (nonatomic, copy, readonly) void (^animateInBlock)(void); ///< PublishViewController wants this to be called by animators

// Upload Parameters
@property (nonatomic, strong) NSURL *mediaToUploadURL; ///< The URL of the media that will be uploaded
@property (nonatomic, assign) BOOL isGIF; ///< Bool indicating whether or not this content is a gif.
@property (nonatomic, strong) NSNumber *parentSequenceID; ///< The parent sequence ID, if any.
@property (nonatomic, strong) NSNumber *parentNodeID; ///< The parent node ID, if any.
@property (nonatomic, strong) NSString *filterName; ///< The filter name, if any.
@property (nonatomic, strong) NSString *embeddedText; ///< The text emebedded in content, if any.
@property (nonatomic, strong) NSString *textToolType; ///< The text tool used, if any.
@property (nonatomic, assign) BOOL didCrop; ///< YES if the user did crop.
@property (nonatomic, assign) BOOL didTrim; ///< YES if the user did trim.

@end
