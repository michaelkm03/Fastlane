//
//  VActionBarTruncation.h
//  victorious
//
//  Created by Michael Sena on 4/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Object that conform to this protocol inform their containing VActionBar 
 *  that they can be truncated.
 */
@protocol VActionBarTruncation <NSObject>

- (CGSize)minimumSize;

@end
