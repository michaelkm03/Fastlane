//
//  VContentToStreamAnimator.h
//  victorious
//
//  Created by Will Long on 3/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VContentToStreamAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) NSIndexPath* indexPathForSelectedCell;
@end
