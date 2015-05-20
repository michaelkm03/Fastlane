//
//  VCoachmarkManager.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VCoachmarkManager : NSObject

#warning DOCS INCOMPLETE

/**
    Creates a new coachmark manager with the provided dependency manager.
    The coachmark manager will populate it's coachmarks based on coachmark objects present
    in the provided dependency manager.
 
    @param dependencyManager A dependency manager that contains coachmarks that this class should display
 
    @return A coachmark manager populated with all coachmarks from the provided dependency manager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
    Displays a coachmark in the provided view controller if possible.
 
    @param viewController The view controller that will house the coachmark
 */
- (void)displayCoachmarkViewInViewController:(UIViewController *)viewController withIdentifier:(NSString *)identifier;

- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)saveStateOfCoachmarks;

@end
