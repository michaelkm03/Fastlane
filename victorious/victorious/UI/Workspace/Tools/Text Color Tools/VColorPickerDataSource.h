//
//  VColorPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VColorPickerDataSource.h"
#import "VCollectionToolPicker.h"

@class VDependencyManager;

/**
 A datasource for a VCollectionToolPicker that provides color options while
 editing during content creation, usually for a text post.
 */
@interface VColorPickerDataSource : NSObject <VCollectionToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
