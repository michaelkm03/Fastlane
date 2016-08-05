//
//  NSString+VParseHelp.h
//  VictoriOS
//
//  Created by Will Long on 11/18/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VConstants.h"

@interface NSString (VParseHelp)

/**
 If the string is a URL, this method returns the path component of that URL.
 */
- (NSString *)v_pathComponent;

@end
