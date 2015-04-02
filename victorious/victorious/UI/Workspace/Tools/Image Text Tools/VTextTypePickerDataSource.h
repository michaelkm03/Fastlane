//
//  VTextTypePickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCollectionToolPicker.h"

@class VDependencyManager;

/**
 A data source that provides data to a VToolPicker providing options for various
 kinds of text annotations that can be added to an image post, such as quote and meme.
 */
@interface VTextTypePickerDataSource : NSObject <VCollectionToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
