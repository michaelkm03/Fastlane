//
//  VWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VWorkspaceTool <NSObject>

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display while selecting tool
@property (nonatomic, strong, readonly) UIImage *icon; ///< The icon to display for this tool
@property (nonatomic, strong, readonly) NSArray *subTools; ///< The subtools if any for this tool

@end
