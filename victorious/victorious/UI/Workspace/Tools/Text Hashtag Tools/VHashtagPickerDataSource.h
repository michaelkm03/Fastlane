//
//  VHashtagPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VMultipleToolPicker.h"
#import "VCollectionToolPicker.h"

@class VDependencyManager;

@interface VHashtagPickerDataSource : NSObject <VCollectionToolPickerDataSource>

@property (nonatomic, weak) id<VCollectionToolPicker> toolPicker;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion;

- (id<VWorkspaceTool>)toolForHashtag:(NSString *)hashtagText;

@end
