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

@interface VTextTypePickerDataSource : NSObject <VCollectionToolPickerDataSource>

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

@end
