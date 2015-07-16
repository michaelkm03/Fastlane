//
//  VListicleView.h
//  victorious
//
//  Created by Steven F Petteruti on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VSequence;

/*
 *  A custom view for displaying the listicle banner
 */
@interface VListicleView : UIView <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong) NSString *headlineText; //< the text to be displayed

@end
