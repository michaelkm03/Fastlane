//
//  VMarqueeTabIndicatorView.h
//  victorious
//
//  Created by Will Long on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A view that can be used to display tabs.
 */
@interface VFullscreenMarqueeTabIndicatorView : UIView

@property (nonatomic) NSUInteger numberOfTabs;///<Number of tabs to display.  Calls updateUI when changed.
@property (nonatomic) NSUInteger currentlySelectedTab;///<Currently selectedTab. Animates selection when changed.
@property (nonatomic) CGFloat spacingBetweenTabs;///<Spacing between tabs.  Calls updateUI when changed.

@property (nonatomic, strong) UIImage *tabImage;///<The image to use for a tab.  Calls updateUI when changed.
@property (nonatomic, strong) UIColor *selectedColor;///<The selection color.  Calls updateUI when changed.
@property (nonatomic, strong) UIColor *deselectedColor;///<The deselection color.  Calls updateUI when changed.

- (void)updateUI;///<Updates the UI.  Is called whenever numberOfTabs, tabImage, selectedColor, deselectedColor or spacingBetweenTabs are changed.

@end
