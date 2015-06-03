//
//  VActionBarFlexibleWidth.h
//  victorious
//
//  Created by Michael Sena on 4/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VActionBarFlexibleWidth <NSObject>

/**
 *  Return yes to inform VActionBar that this view can be stretched 
 *  horizontally like a flexible width item.
 */
- (BOOL)canApplyFlexibleWidth;

@end
