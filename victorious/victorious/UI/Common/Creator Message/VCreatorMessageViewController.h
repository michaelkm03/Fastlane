//
//  VCreatorMessageViewController.h
//  victorious
//
//  Created by Patrick Lynch on 6/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class VDependencyManager;

@interface VCreatorMessageViewController : UIViewController <VHasManagedDependencies>

- (void)setMessage:(NSString *)message;

@end
