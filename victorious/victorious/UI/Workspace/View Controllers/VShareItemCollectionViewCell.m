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

#pragma mark - Cell setup methods

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.button.layer.borderWidth = 1.0f;
}

- (void)populateWithShareMenuItem:(VShareMenuItem *)menuItem andDependencyManager:(VDependencyManager *)dependencyManager
{
    self.dependencyManager = dependencyManager;
    self.shareMenuItem = menuItem;
    self.state = VShareItemCellStateUnselected;
    [self.button setImage:[menuItem.icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.button setImage:[menuItem.selectedIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    self.button.activityIndicatorTintColor = [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
}

#pragma mark - Setters

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
    [self updateButtonTintColor];
}

#pragma mark - Private methods

- (void)updateButtonTintColor
{
    UIColor *tintColor = self.state == VShareItemCellStateSelected ? [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey] : [self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey];
    self.button.tintColor = tintColor;
    self.button.layer.borderColor = tintColor.CGColor;
}

@end
