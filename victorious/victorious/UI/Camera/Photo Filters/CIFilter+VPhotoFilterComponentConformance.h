//
//  CIFilter+VPhotoFilterComponentConformance.h
//  victorious
//
//  Created by Josh Hinman on 8/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPhotoFilterComponent.h"

@import CoreImage;

/**
 Adds VPhotoFilterComponent conformance to CIFilter
 */
@interface CIFilter (VPhotoFilterComponentConformance) <VPhotoFilterComponent>

@end
