//
//  VContentCommentSegue.m
//  victorious
//
//  Created by Will Long on 3/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentCommentSegue.h"

#import "VContentViewController.h"
#import "VCommentsContainerViewController.h"
#import "VKeyboardBarViewController.h"

#import "UIView+VFrameManipulation.h"

@implementation VContentCommentSegue

- (void)perform
{
    //Custom animation code
    VContentViewController* contentVC = self.sourceViewController;
//    VCommentsContainerViewController* commentVC = self.destinationViewController;

    [UIView animateWithDuration:.5f
                     animations:^
     {
         for (UIView* view in contentVC.view.subviews)
         {
             if ([view isKindOfClass:[UIImageView class]])
                 continue;

             if (view.center.y > contentVC.view.center.y)
             {
                 view.center = CGPointMake(view.center.x, view.center.y + contentVC.view.frame.size.height);
             }
             else
             {
                 view.center = CGPointMake(view.center.x, view.center.y - contentVC.view.frame.size.height);
             }
         }
     }
                     completion:^(BOOL finished)
     {
         [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
     }];
}

@end
