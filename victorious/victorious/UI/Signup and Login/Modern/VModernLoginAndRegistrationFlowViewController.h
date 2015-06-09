//
//  VModernLoginAndRegistrationFlowViewController.h
//  victorious
//
//  Created by Michael Sena on 5/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLoginRegistrationFlow.h"
#import "VHasManagedDependencies.h"

/**
 *  ATTENTION: Do not modify the navigation controller's delegate.
 *
 *  This flow controller dismisses itself when finished. The VLoginRegistrationFlow completion
 *  block will be called after any dismissal has completed.
 */
@interface VModernLoginAndRegistrationFlowViewController : UINavigationController <VLoginRegistrationFlow, VHasManagedDependencies>

@end
