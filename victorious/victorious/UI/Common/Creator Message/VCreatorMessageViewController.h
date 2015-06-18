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

/**
 A reuable view controller that shows some text as a quote from the creator,
 using an avatar and creator name as a salutation.
 */
@interface VCreatorMessageViewController : UIViewController <VHasManagedDependencies>

/**
 The messages to display, appearing beneath styled quotes as if spoken by the creator.
 */
- (void)setMessage:(NSString *)message;

@end
