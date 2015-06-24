//
//  VStandardCreationFlowController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStandardCreationFlowController.h"

@interface VStandardCreationFlowController ()

@end

@implementation VStandardCreationFlowController

- (void)cancel
{
    if ([self.creationFlowDelegate respondsToSelector:@selector(creationFlowControllerDidCancel:)])
    {
        [self.creationFlowDelegate creationFlowControllerDidCancel:self];
    }
    else
    {
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
    }
}

@end
