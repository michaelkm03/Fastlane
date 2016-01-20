//
//  VKeyboardBarContainerViewController.h
//  victorious
//
//  Created by David Keegan on 1/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#include "VKeyboardBarViewController.h"

@class VConversationViewController;

@interface VKeyboardBarContainerViewController : UIViewController <VHasManagedDependencies, VKeyboardBarDelegate>

@property (weak, nonatomic) VKeyboardBarViewController *keyboardBarViewController;
@property (strong, nonatomic) IBOutlet UIView *topConstraintView;
@property (strong, nonatomic) VConversationViewController *innerViewController;
@property (strong, nonatomic) VDependencyManager *dependencyManager;
@property (assign, nonatomic) CGFloat keyboardBarHeight;

@end
