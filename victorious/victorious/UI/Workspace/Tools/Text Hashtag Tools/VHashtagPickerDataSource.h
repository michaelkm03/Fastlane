//
//  VHashtagPickerDataSource.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VToolPicker.h"

@class VDependencyManager;

@interface VHashtagPickerDataSource : NSObject <VToolPickerDataSource>

@property (nonatomic, weak) id<VToolPicker> toolPicker;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion;

- (id<VWorkspaceTool>)toolForHashtag:(NSString *)hashtagText;

@end
