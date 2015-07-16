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
 *  A Stream header view for displaying information about a sequence.
 *  It displays the listicle banner.
 */
@interface VListicleView : UIView <VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;


/*
 *  Draws the banner for the listicle with the given text
 */
- (void)drawBannerWithText:(NSString *)text;

@end
