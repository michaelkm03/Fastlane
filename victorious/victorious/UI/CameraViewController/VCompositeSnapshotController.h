//
//  VCompositeSnapshotController.h
//  victorious
//
//  Created by Will Long on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VCompositeSnapshotController : NSObject

- (UIImage*)snapshotOfMainView:(UIView*)mainView subViews:(NSArray*)subviews;

@end
