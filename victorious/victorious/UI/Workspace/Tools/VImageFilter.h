//
//  VImageFilter.h
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VWorkspaceTool.h"
#import "VPhotoFilter.h"

@interface VImageFilter : NSObject <VWorkspaceTool>

@property (nonatomic, strong) VPhotoFilter *filter;

@end
