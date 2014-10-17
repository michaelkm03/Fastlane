//
//  UIViewController+VNavMenu.h
//  victorious
//
//  Created by Will Long on 10/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VNavigationHeaderView.h"

@interface UIViewController (VNavMenu)

@property (nonatomic, strong) VNavigationHeaderView *navHeaderView;

- (void)addNewNavHeaderWithTitles:(NSArray *)titles;
- (void)hideHeader;
- (void)showHeader;
- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView;
- (void)menuPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView;

@end
