//
//  VTwitterHelper.h
//  victorious
//
//  Created by Michael Sena on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ACAccount;

/**
 *  The selection block type for the account selection helper. 
 *  Twitter account may be nil if permission was denied or the user cancelled.
 */
typedef void (^VTwitterAccountsHelperCompletion)(ACAccount *twitterAccount);

/**
 *  A VTwitterAccountsHelper assists a viewController with selecting among the user's twitter accounts.
 */
@interface VTwitterAccountsHelper : NSObject

/**
 *  Use this method to allow the user to select a twitter account.
 *
 *  @param viewControllerToPresentOnIfNeeded In the event of a failure, an alert will be presented on this viewcontorller. In the event of the user having multiple twitter accounts, a VSelectorViewController will be presented on this viewController for selection.
 *  @param completion A completion block.
 */
- (void)selectTwitterAccountWithViewControler:(UIViewController *)viewControllerToPresentOnIfNeeded
                                   completion:(VTwitterAccountsHelperCompletion)completion;

@end
