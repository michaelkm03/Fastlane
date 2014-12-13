//
//  VTextType.h
//  victorious
//
//  Created by Michael Sena on 12/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VHasManagedDependencies.h"
#import "VWorkspaceTool.h"

typedef NS_ENUM(NSInteger, VTextTypeVerticalAlignment)
{
    VTextTypeVerticalAlignmentCenter, ///< Text should be aligned center (like secret)
    VTextTypeVerticalAlignmentBottomUp, ///< Text should be aligned to the bottom and grow up
};

@interface VTextTypeTool : NSObject

@property (nonatomic, readonly) VTextTypeVerticalAlignment verticalAlignment;
@property (nonatomic, readonly) NSDictionary *attributes;
@property (nonatomic, readonly) UIColor *dimmingBackgroundColor;

@end
