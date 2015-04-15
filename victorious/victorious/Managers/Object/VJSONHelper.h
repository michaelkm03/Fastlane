//
//  VJSONHelper.h
//  victorious
//
//  Created by Josh Hinman on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Contains functions that help when dealing with JSON data
 */
@interface VJSONHelper : NSObject

/**
 Returns the given JSON value as an NSNumber, or nil
 if the given JSON value could not be converted into
 an NSNumber.
 */
- (NSNumber *)numberFromJSONValue:(id)value;

@end
