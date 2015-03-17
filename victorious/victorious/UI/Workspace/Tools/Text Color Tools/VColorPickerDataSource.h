//
//  VColorPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VColorPickerDataSource.h"
#import "VToolPicker.h"

@class VDependencyManager;

@interface VColorPickerDataSource : NSObject <VToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager colors:(NSArray *)colors;

@end
