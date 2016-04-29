//
//  VCoachmarkManager.h
//  victorious
//
//  Created by Sharif Ahmed on 5/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VCoachmarkDisplayer.h"
#import "VHasManagedDependencies.h"

@class VDependencyManager;

extern NSString * const VLikeButtonCoachmarkIdentifier;

/**
    An object that manages the retrieval, displaying,
    and hiding of coachmarks in view controllers.
 */
@interface VCoachmarkManager : NSObject <VHasManagedDependencies>

/**
    Creates a new coachmark manager with the provided dependency manager.
    The coachmark manager will populate it's coachmarks based on coachmark objects present
    in the provided dependency manager.
 
    @param dependencyManager A dependency manager that contains coachmarks that this class should display
 
    @return A coachmark manager populated with all coachmarks from the provided dependency manager
 */
- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
    Clears shown states of coachmarks from NSUserDefaults
 */
- (void)resetShownCoachmarks;

/**
    Displays a coachmark in the provided view controller if possible.
    This method uses the viewController's responder chain to find a suitable menu item to point to
    when appropriate. To support this, this method must be called at or after viewDidAppear.
 
    @param viewController The view controller that will house the coachmark
 
    @return YES when a coachmark will attempt to display after a delay, NO otherwise
 */
- (BOOL)displayCoachmarkViewInViewController:(UIViewController <VCoachmarkDisplayer> *)viewController;

/**
    Manually shows a tooltip coachmark in the provided view controller if possible
 
    @param remoteID The ID of the coachmark you'd like to show
    @param viewController The view controller that will house the coachmark
    @param location of the view which the coachmark tooltip will point toward
  */
- (void)triggerSpecificCoachmarkWithIdentifier:(NSString *)remoteID inViewController:(UIViewController *)viewController atLocation:(CGRect)location;

/**
    Hides the coachmark view associated with the provided view controller.
    This method should be called from viewWillDisappear.
 
    @param viewController The view controller that is currently displaying a coachmark.
    @param animated Whether or not the coachmark should dismiss with a fade animation.
 */
- (void)hideCoachmarkViewInViewController:(UIViewController *)viewController animated:(BOOL)animated;

/**
    Whether or not coachmarks should be added to view controllers provided to displayCoachmarkViewInViewController:
    Defaults to NO
 */
@property (nonatomic, assign) BOOL allowCoachmarks;

@end
