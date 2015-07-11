//
//  SwiftBridging.h
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/**
 Use this file to import Objective-C headers that need to be exposed to any Swift code.
 Unlike other lists of Objective-C important statements, this list is actually important
 and should be kept organized and commented.
 */

// iOS Frameworks
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

// RestKit
#import "RKEntityMapping.h"
#import "RKObjectManager.h"
#import "RKManagedObjectStore.h"
#import "RKEntityMapping.h"
#import "RKManagedObjectCaching.h"
#import "RKManagedObjectRequestOperation.h"
#import "RKResponseDescriptor.h"
#import "RKHTTPUtilities.h"

// SDWebImage
#import <SDWebImage/UIImageView+WebCache.h>

// Victorious Models
#import "VAbstractFilter.h"
#import "VSEquence.h"

#import "VTextPostTextView.h"
#import "VObjectManager.h"
#import "VPaginationManager.h"
#import "VPageType.h"
#import "VCaptureContainerViewController.h"
#import "VMediaSource.h"
#import "VVideoView.h"
#import "UIImage+VTint.h"