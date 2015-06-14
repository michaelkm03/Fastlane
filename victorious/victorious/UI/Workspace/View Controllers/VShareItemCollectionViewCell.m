//
//  VShareItemCollectionViewCell.m
//  victorious
//
//  Created by Sharif Ahmed on 6/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VShareItemCollectionViewCell.h"
#import "VShareMenuItem.h"
#import "VButton.h"
#import "VDependencyManager.h"

@interface VShareItemCollectionViewCell ()

@property (nonatomic, weak) IBOutlet VButton *button;
@property (nonatomic, readwrite) VShareMenuItem *shareMenuItem;

@end

@implementation VShareItemCollectionViewCell

- (void)populateWithShareMenuItem:(VShareMenuItem *)menuItem andDependencyManager:(VDependencyManager *)dependencyManager
{
    self.dependencyManager = dependencyManager;
    self.shareMenuItem = menuItem;
    self.state = VShareItemCellStateUnselected;
    [self.button setImage:[menuItem.icon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.button setImage:[menuItem.selectedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateSelected];
    self.button.tintColor = [UIColor clearColor];
    self.button.activityIndicatorTintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
}

- (void)setState:(VShareItemCellState)state
{
    _state = state;
    
    // Update state of button
    if ( state == VShareItemCellStateLoading )
    {
        [self.button showActivityIndicator];
    }
    else
    {
        [self.button hideActivityIndicator];
        BOOL isSelected = state == VShareItemCellStateSelected;
        self.button.selected = isSelected;
    }
    [self updateBorderColor];
}

- (void)updateBorderColor
{
    UIColor *borderColor = self.state == VShareItemCellStateSelected ? [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey] : [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    [self setBorderColor:borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor
{
    self.button.layer.borderColor = borderColor.CGColor;
    self.button.layer.borderWidth = 1.0f;
}

@end
