//
//  VStreamTransitioningDelegate.h
//  victorious
//
//  Created by Will Long on 3/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VStreamTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) NSIndexPath* indexPathForSelectedCell;
@end
