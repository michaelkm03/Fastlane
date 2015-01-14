//
//  UIViewController+VSideMenuViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIViewController+VSideMenuViewController.h"

@implementation UIViewController (VSideMenuViewController)

- (VSideMenuViewController *)sideMenuViewController
{
    UIViewController *vc = self.parentViewController;
    while (vc)
    {
        if ([vc isKindOfClass:[VSideMenuViewController class]])
        {
            return (VSideMenuViewController *)vc;
        }
        else if (vc.parentViewController && vc.parentViewController != vc)
        {
            vc = vc.parentViewController;
        }
        else
        {
            vc = nil;
        }
    }

    return nil;
}

@end
