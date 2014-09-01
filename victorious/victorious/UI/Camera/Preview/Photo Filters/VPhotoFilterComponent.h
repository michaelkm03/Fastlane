//
//  VPhotoFilterComponent.h
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import Foundation;
@import CoreImage;

/**
 Objects conforming to this protocol perform one filtering step in a multi-step filter process
 */
@protocol VPhotoFilterComponent <NSObject, NSCopying>
@required

/**
 Applies the receiver's modifications to an image, and returns the result.
 
 @param size        The size of the image, in pixels
 @param orientation The orientation of the image
 */
- (CIImage *)imageByFilteringImage:(CIImage *)inputImage size:(CGSize)size orientation:(UIImageOrientation)orientation;

@end
