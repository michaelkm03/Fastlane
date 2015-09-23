//
//  NSNumber+VBitmask.h
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (VBitmask)

/**
 Returns a string representation of the value as a bitmask, such as "0000000 0010010".
 This is useful for debugging purposes and is not intended to be displayed to users.
 */
- (NSString *)v_bitmaskString;

/**
 Returns a string representation of the provided value as a bitmask, such as "0000000 0010010".
 This is useful for debugging purposes and is not intended to be displayed to users.
 */
+ (NSString *)v_bitmaskString:(NSInteger)integerValue;

@end
