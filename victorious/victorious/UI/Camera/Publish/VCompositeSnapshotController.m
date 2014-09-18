//
//  VCompositeSnapshotController.m
//  victorious
//
//  Created by Will Long on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCompositeSnapshotController.h"

@implementation VCompositeSnapshotController

- (UIImage *)snapshotOfMainView:(UIView *)mainView subViews:(NSArray *)subviews
{
    UIView *compositeView = [[UIView alloc] initWithFrame:mainView.frame];
    
    UIGraphicsBeginImageContextWithOptions(compositeView.bounds.size, YES, 0);
    [mainView drawViewHierarchyInRect:compositeView.bounds afterScreenUpdates:YES];
    
    for (UIView *subview in subviews)
    {
        CGRect rect = [mainView convertRect:subview.frame fromView:subview.superview];
        [subview drawViewHierarchyInRect:rect afterScreenUpdates:YES];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
