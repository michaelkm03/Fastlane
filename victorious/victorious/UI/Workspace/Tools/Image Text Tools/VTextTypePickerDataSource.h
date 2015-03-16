//
//  VTextTypePickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VToolPickerDataSource.h"

@class VDependencyManager;

@interface VTextTypePickerDataSource : NSObject <VToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager tools:(NSArray *)tools;

@end
