//
//  VBadgeResponder.h
//  victorious
//
//  Created by Steven F Petteruti on 7/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIViewController;

/*
 *  Used to notify the reciever that the badges need to be updated. 
 *  Should be called by view controllers whose badges need to be update.
 *  e.g., when the user recieved a push notification.
 */
@protocol VBadgeResponder <NSObject>

- (void)updateBadge;

@end
