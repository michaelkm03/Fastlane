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

@interface VModernLoginAndRegistrationFlowViewController : UINavigationController <VLoginRegistrationFlow, VHasManagedDependencies>

@end
