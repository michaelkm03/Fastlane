//
//  VSleekActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractActionView.h"
#import "VHasManagedDependencies.h"
#import "VRoundedBackgroundButton.h"

/**
 *  An VAbstractActionView for sleek cells.
 */
@interface VSleekActionView : VAbstractActionView <VHasManagedDependencies>

@property (nonatomic, strong, readonly) VRoundedBackgroundButton *likeButton;

@end
