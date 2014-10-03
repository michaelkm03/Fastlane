//
//  VAuthorizationViewControllerFactory.h
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VAuthorizationViewControllerFactory : NSObject

/**
 @brief Instantiates a view controller appropriate for the main user's current level of authorization
 */
+ (UIViewController *)requiredViewController;

@end
