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

@interface VColorPickerDataSource : NSObject <VCollectionToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
