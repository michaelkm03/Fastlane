//
//  VContentFittingPreviewView.h
//  victorious
//
//  Created by Sharif Ahmed on 7/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    Describes preview views that can update their content mode.
 */
@protocol VContentFittingPreviewView <NSObject>

/**
    Conformers should use this method to update the content view of their content-displaying
        views to fit or their default state.
 
    @property fit Whether or not content should fit within the preview view or use the default content mode.
 */
- (void)updateToFitContent:(BOOL)fit;

@end
