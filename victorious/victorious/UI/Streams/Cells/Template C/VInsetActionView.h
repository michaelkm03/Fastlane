//
//  VInsetActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractActionView.h"
#import "VHasManagedDependencies.h"
#import "VActionButton.h"

/**
 *  VInsetActionView is a VAbstractActionView subclass for use in insetCollectionCells.
 */
@interface VInsetActionView : VAbstractActionView <VHasManagedDependencies>

@property (nonatomic, strong, readonly) VActionButton *repostButton;
@property (nonatomic, strong, readonly) VActionButton *commentButton;
@property (nonatomic, strong, readonly) VActionButton *likeButton;

@end
