//
//  NSString+VDisplayCheck.h
//  victorious
//
//  Created by Sharif Ahmed on 3/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
Simple checks to confirm that strings are valid for display
 */
@interface NSString (VDisplayCheck)

//Returns yes if string is not equal to "", no otherwise
- (BOOL)isValidForDisplay;

@end
