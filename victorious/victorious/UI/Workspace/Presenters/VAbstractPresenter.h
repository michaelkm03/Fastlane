//
//  VAbstractPresenter.h
//  victorious
//
//  Created by Michael Sena on 6/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

/**
 *  VAbstractPresenter defines an interface and base behavior for presenters. Presenters are transient objects 
 *  that are not retained. If you provide a VAbstractPresenter subclass with a completion block you must retain the presenter.
 */
@interface VAbstractPresenter : NSObject

/**
 *  The designated initializer for VAbstractPresenter. All parameters are required.
 */
- (instancetype)initWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn
                                dependencymanager:(VDependencyManager *)dependencyManager NS_DESIGNATED_INITIALIZER;

/**
 *  Subclasses will override this method to perform the appropriate presentation.
 */
- (void)present;

/**
 *  The UIViewController to present on. Passed into the designated initializer.
 */
@property (nonatomic, readonly) UIViewController *viewControllerToPresentOn;

/**
 *  A dependency manager to use. Passed into the designated initializer.
 */
@property (nonatomic, readonly) VDependencyManager *dependencyManager;

@end
