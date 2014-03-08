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
    VCommentsContainerViewController* commentVC = self.destinationViewController;

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
//         __block CGFloat originalKeyboardY = commentVC.keyboardBarViewController.view.frame.origin.y;
//         __block CGFloat originalConvertationX = commentVC.conversationTableViewController.view.frame.origin.y;
//         [commentVC.conversationTableViewController.view setXOrigin:commentVC.view.frame.size.width];
//         [commentVC.keyboardBarViewController.view setYOrigin:commentVC.view.frame.size.height];
//
//         [UIView animateWithDuration:.2f
//                          animations:^{
//                              [commentVC.conversationTableViewController.view setXOrigin:originalConvertationX];
//                               }
//                          completion:^(BOOL finished) {
//                              [UIView animateWithDuration:.5f
//                                               animations:^{
//                                                   [commentVC.keyboardBarViewController.view setYOrigin:originalKeyboardY];
//                                               }
//                                               completion:^(BOOL finished) {
//                                                   
//                                                   [self.sourceViewController presentModalViewController:self.destinationViewController animated:NO];
//                                               }];
//                          }];
     }];
}

@end
