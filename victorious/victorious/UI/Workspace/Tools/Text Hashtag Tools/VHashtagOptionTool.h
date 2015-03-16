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

/**
 *  VImageFilter is a simple model class for use in VPickers.
 */
@interface VHashtagOptionTool : NSObject <VWorkspaceTool>

@property (nonatomic, strong) NSString *hashtag;

@end
