//
//  VPreviewViewBackgroundHost.h
//  victorious
//
//  Created by Sharif Ahmed on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VBackgroundContainer.h"

/**
    Describes preview views that can update their content mode and add a background view that will
        be animated alongside the content.
 */
@protocol VPreviewViewBackgroundHost <NSObject, VBackgroundContainer>

/**
    Conformers should use this method to update the content view of their content-displaying
        views to fit or their default state and apply the background from the provided dependency manager.
 
    @property fit Whether or not content should fit within the preview view or use the default content mode.
    @property dependencyManager A dependency manager that should be used to supply a background to the preview view.
 */
- (void)updateToFitContent:(BOOL)fit withBackgroundSupplier:(VDependencyManager *)dependencyManager;

@end
