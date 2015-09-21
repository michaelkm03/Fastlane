//
//  NSNumber+VBitmask.h
//  victorious
//
//  Created by Patrick Lynch on 9/21/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (VBitmask)

- (NSString *)v_bitmaskString;

+ (NSString *)v_bitmaskString:(NSInteger)integerValue;

@end
