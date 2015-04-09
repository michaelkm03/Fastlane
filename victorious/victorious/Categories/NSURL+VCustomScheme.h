//
//  NSURL+VCustomScheme.h
//  victorious
//
//  Created by Patrick Lynch on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (VCustomScheme)

/**
 @return YES if the scheme of the URL is not "http" or "https"
 */
- (BOOL)v_hasCustomScheme;

/**
 @return YES if the scheme matches the Victorious generic scheme that indicates
 a deep link should be opened in the current app.
 
 @see https://wiki.victorious.com/display/ENG/Deep+Linking+Specification
 */
- (BOOL)v_isThisAppGenericScheme;

@end
