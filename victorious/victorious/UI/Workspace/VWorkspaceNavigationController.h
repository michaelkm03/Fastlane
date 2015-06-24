//
//  VWorkspaceNavigationController.h
//  victorious
//
//  Created by Sharif Ahmed on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
    A navigation controller that will display an alert when
    the "showAlertWhenAppearing" bool is set to YES before displaying.
 */
@interface VWorkspaceNavigationController : UINavigationController

/**
    When set to YES before presenting, this navigation controller
    will display a failure alert when it becomes visible.
 */
@property (nonatomic, assign) BOOL showAlertWhenAppearing;

@end
