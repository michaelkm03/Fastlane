//
//  VDependencyManager+VNavigationItem.m
//  victorious
//
//  Created by Josh Hinman on 2/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <objc/runtime.h>
#import "VDependencyManager+VNavigationItem.h"
#import "VNavigationMenuItem.h"
#import "VNavigationTitleView.h"

NSString * const VDependencyManagerTitleImageKey = @"titleImage";

@interface VDependencyManager()

@property (nonatomic, strong) VDependencyManager *parentManager;

@end

@implementation VDependencyManager (VNavigationItem)

- (void)configureNavigationItem:(UINavigationItem *)navigationItem
{
    NSString *title = [self stringForKey:VDependencyManagerTitleKey];
    if ( title != nil )
    {
        navigationItem.title = title;
    }
    
    UIImage *titleImage = [self imageForKey:VDependencyManagerTitleImageKey];
    if ( titleImage != nil )
    {
        VNavigationTitleView *titleView = [[VNavigationTitleView alloc] initWithTitleView:[[UIImageView alloc] initWithImage:titleImage] withPreferredSize:titleImage.size];
        navigationItem.titleView = titleView;
    }
}

@end
