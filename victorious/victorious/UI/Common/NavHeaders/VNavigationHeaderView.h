//
//  VNavigationHeaderView.h
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VNavigationSelectorProtocol.h"
#import "VHeaderView.h"

@class VNavigationHeaderView;

@protocol VNavigationHeaderDelegate <NSObject>

@optional

/**
 *  Callback when the back button is pressed
 *
 *  @param navHeaderView The NavigationHeaderview that pressed back
 */
- (void)backPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView;

/**
 *  Callback when the menu button is pressed
 *
 *  @param navHeaderView The NavigationHeaderview that pressed menu
 */
- (void)menuPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView;

/**
 *  Callback that handles the changed index
 *
 *  @param index New index that was selected
 *
 *  @return Return YES if the index is valid, return NO if the index cannot currently be selected (e.g. User needs to log in first)
 */
- (BOOL)navSelector:(UIView<VNavigationSelectorProtocol> *)navSelector changedToIndex:(NSInteger)index;

@end

/**
 *  Provides a themed Victorious header view that has options for: filters, adding content, side menu, back nav action, and the custom header logo.
 */
@interface VNavigationHeaderView : VHeaderView

/**
 *  Shows the header logo image when set to yes.
 */
@property (nonatomic) BOOL showHeaderLogoImage;

/**
 *  Text to show on the header.  Will not display after you call showHeaderLogo.
 */
@property (nonatomic, strong) NSString *headerText;

@property (nonatomic, weak) id<VNavigationHeaderDelegate> delegate;

@property (nonatomic, weak, readonly) UIView<VNavigationSelectorProtocol> *navSelector;

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles;
+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles;

/**
 *  Updates the UI of the header view.  Call after the VC's viewDidLoad.  This will swap the back / menu buttons to the appropriate state based on the VC's nav stack.
 *
 *  @param viewController The view controller that owns the header.
 */
- (void)updateUIForVC:(UIViewController *)viewController;

/**
 *  Sets the image for the right button.  If the image is nil, it hides the button.  If its not nil, it unhides the button.
 *
 */
- (UIButton *)setRightButtonImage:(UIImage *)image
                 withAction:(SEL)action
                   onTarget:(id)target;

/**
 *  Sets the title for the right button.  If the title is nil, it hides the button.  If its not nil, it unhides the button.
 *
 */
- (UIButton *)setRightButtonTitle:(NSString *)title
                 withAction:(SEL)action
                   onTarget:(id)target;

/**
 Updates the number in the badge on the menu button
 */
- (void)setBadgeNumber:(NSInteger)badgeNumber;

@end
