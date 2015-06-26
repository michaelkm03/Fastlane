//
//  VCreationFlowPresenter.h
//  victorious
//
//  Created by Michael Sena on 3/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager;

@interface VCreationFlowPresenter : NSObject

/**
 A Boolean that determines whether or not the creation sheet shows its
 animation from the top of the screen.
 */
@property (nonatomic, assign) BOOL showsCreationSheetFromTop;

+ (instancetype)creationFlowPresenterWithViewControllerToPresentOn:(UIViewController *)viewControllerToPresentOn dependencyManager:(VDependencyManager *)dependencyManager;

- (void)present;

@end
