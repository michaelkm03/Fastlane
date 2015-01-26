//
//  VPhotoFilter.h
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 An instance of VPhotoFilter contains a list of CIFilter instances
 and a means to easily apply those filters to a UIImage.
 */
@interface VPhotoFilter : NSObject <NSCopying>

@property (nonatomic, copy) NSString                                *name;       ///< The filter's catchy name
@property (nonatomic, copy) NSArray /* id<VPhotoFilterComponent> */ *components; ///< The VPhotoFilterComponent objects that define this filter

/**
 Return a new image by sending the given sourceImage through
 each of the receiver's CIFilter instances.
 */
- (UIImage *)imageByFilteringImage:(UIImage *)sourceImage withCIContext:(CIContext *)context;

/**
 Applies this filter to the input image over it's extent. Assumes UIImageOrientationUP.
 */
- (CIImage *)filteredImageWithInputImage:(CIImage *)inputImage;

@end
