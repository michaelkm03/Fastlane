//
//  VFilterWorkspaceTool.h
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

#import "VPhotoFilter.h"

@interface VFilterWorkspaceTool : NSObject <VHasManagedDependancies, VWorkspaceTool>

@property (nonatomic, copy) void (^onFilterChange)(VPhotoFilter *filter);

@end
