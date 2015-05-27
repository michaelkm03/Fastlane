//
//  VCoachmarkDisplayResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^VMenuItemDiscoveryBlock) (BOOL found, CGRect location);

/**
    Objects that conform to this protocol determine the exact frames of the menu
    items in relation to the menu item's furthest parent view. If a menu item
    should display a coachmark, an object that conforms to this protocol must
    describe the frame of that menu item and be in the responder chain of the
    view controller that wants to present a coachmark.
 */
@protocol VCoachmarkDisplayResponder <NSObject>

/**
    Implementers of this method should return the absolute frame of a button
    representing the screen with the provided identifier. If the screen is not
    found, implementers should attempt to call this method on the next responder.
 
    @param identifier The identifier of the screen whose menu button that should be located.
    @param completion The block that should be called on after a menu button is located.
 */
@required
- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion;

@end
