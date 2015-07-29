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
 */
@protocol VBadgeResponder <NSObject>

- (void)updateBadge;

@end
