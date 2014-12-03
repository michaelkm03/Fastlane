//
//  VCategoryWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VWorkspaceTool.h"

@interface VCategoryWorkspaceTool : NSObject <VWorkspaceTool>

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
                     subTools:(NSArray *)subTools;

@end
