//
//  VCreationFlowShim.h
//  victorious
//
//  Created by Michael Sena on 6/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VWorkspaceFlowController;
@class VTextWorkspaceFlowController;
@class VCreatePollViewController;
@class VCreateSheetViewController;

#warning YOU'RE FINISHED AFTER YOU REMOVE ME

/**
 *  A VCreationFlowShim is a stand-in for the Creation Flow
 *  component from the template spec. Currently just exists to 
 *  fill a spot in the component hierarchy.
 */
@interface VCreationFlowShim : NSObject <VHasManagedDependencies>

- (VCreateSheetViewController *)createSheetViewControllerWithAddedDependencies:(NSDictionary *)dependencies;

- (VTextWorkspaceFlowController *)textFlowController;

- (VCreatePollViewController *)pollFlowController;

- (VWorkspaceFlowController *)imageFlowControllerWithAddedDependencies:(NSDictionary *)dependencies;

@end
