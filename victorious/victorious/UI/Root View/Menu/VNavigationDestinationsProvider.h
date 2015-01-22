//
//  VNavigationDestinationsProvider.h
//  victorious
//
//  Created by Josh Hinman on 1/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Objects (most likely menu view controllers) conforming 
 to this protocol provide a list of destinations that
 the user can navigate to.
 */
@protocol VNavigationDestinationsProvider <NSObject>

@required

/**
 Returns an array of navigation destinations (either UIViewController objects,
 or objects that conform to VNavigationDestination).
 */
- (NSArray *)navigationDestinations;

@end
