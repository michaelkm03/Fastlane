//
//  NSString+RFC2822Date.h
//  victorious
//
//  Created by Michael Sena on 9/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RFC2822Date)

+ (NSString *)stringForRFC2822Date:(NSDate *)date;

@end
