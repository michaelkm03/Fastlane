//
//  NSURL+Validator.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Validator)

/**
   returns NO if the url's absolute string is an empty string
 */
- (BOOL)isValidURL;

@end
