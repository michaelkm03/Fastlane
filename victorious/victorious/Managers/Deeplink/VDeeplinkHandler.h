//
//  VDeeplinkHandler.h
//  victorious
//
//  Created by Josh Hinman on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VNavigationDestination;

/**
 Objects conforming to this protocol are
 able to provide a view controller for
 displaying content pointed to by a
 deep link.
 */
@protocol VDeeplinkHandler <NSObject>

@required

/**
 Returns YES if the receiver knows how to
 display the content pointed to by the
 given URL.
 */
- (BOOL)canHandleDeeplinkURL:(NSURL *)url;

/**
 Tells the receiver to display the content
 pointed to by the given URL.
 */
- (void)displayContentForDeeplinkURL:(NSURL *)url;

@end
