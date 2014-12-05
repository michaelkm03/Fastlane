//
//  VToolPicker.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VWorkspaceTool.h"


@protocol VToolPicker <NSObject>

@property (nonatomic, copy) NSArray /* That implement VWorkspaceTool */ *tools;

@property (nonatomic, readonly) id <VWorkspaceTool> selectedTool;

@property (nonatomic, copy) void (^onToolSelection)(id <VWorkspaceTool> selectedTool);

@end
