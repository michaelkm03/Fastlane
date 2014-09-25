//
//  VNavigationHeaderView.h
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  VNavigationHeaderView;

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
 *  Callback when the add button is pressed
 *
 *  @param navHeaderView The NavigationHeaderview that pressed add
 */
- (void)addPressedOnNavHeader:(VNavigationHeaderView *)navHeaderView;

/**
 *  Callback that handles the changed index
 *
 *  @param index New index that was selected
 *
 *  @return Return YES if the index is valid, return NO if the index cannot currently be selected (e.g. User needs to log in first)
 */
- (BOOL)navHeaderView:(VNavigationHeaderView *)navHeaderView segmentControlChangeToIndex:(NSInteger)index;

@end

/**
 *  Provides a themed Victorious header view that has options for: filters, adding content, side menu, back nav action, and the custom header logo.
 */
@interface VNavigationHeaderView : UIView

/**
 *  Sets the hidden property of the add button
 */
@property (nonatomic) BOOL showAddButton;

/**
 *  Shows the header logo image when set to yes.
 */
@property (nonatomic) BOOL showHeaderLogoImage;

/**
 *  Text to show on the header.  Will not display after you call showHeaderLogo.
 */
@property (nonatomic, strong) NSString *headerText;

@property (nonatomic, weak) id<VNavigationHeaderDelegate> delegate;

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles;
+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles;

/**
 *  Updates the UI of the header view.  Call after the VC's viewDidLoad.
 */
- (void)updateUI;

@end
