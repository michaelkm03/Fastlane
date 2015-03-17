//
//  VFilterPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VToolPicker.h"

@class VDependencyManager;

@interface VFilterPickerDataSource : NSObject <VToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager tools:(NSArray *)tools;

@end
