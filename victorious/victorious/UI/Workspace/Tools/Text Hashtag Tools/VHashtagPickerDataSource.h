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

/**
 A collection view data source designed to provide data to a VCollectionToolPicker,
 which uses a collection view to display data from which users can browse and pick
 from a list of tools that are applicable to the current workspace tool.
 */
@interface VHashtagPickerDataSource : NSObject <VCollectionToolPickerDataSource>

/**
 A reference to the tool picker to which data is being supplied.
 */
@property (nonatomic, weak) id<VCollectionToolPicker> toolPicker;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 Reload the data that this data source provides, after which the completion callback
 will be called with an array of VWorkspaceTool objects to which loaded data has been 
 marshalled.
 */
- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion;

/**
 Given some hashtag text, find the corresponding VWorkspaceTool in this
 data source's tools.  If a corresponding tool does not exist, `nil` will be returned.
 */
- (id<VWorkspaceTool>)toolForHashtag:(NSString *)hashtagText;

@end
