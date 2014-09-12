//
//  VNavigationHeaderView.h
//  victorious
//
//  Created by Will Long on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VNavigationHeaderDelegate <NSObject>

@optional
- (void)backButtonPressed;
- (void)menuButtonPressed;
- (void)addButtonPressed;
/**
 *  Callback that handles the changed index
 *
 *  @param index New index that was selected
 *
 *  @return Return YES if the index is valid, return NO if the index cannot currently be selected (e.g. User needs to log in first)
 */
- (BOOL)segmentControlChangeToIndex:(NSInteger)index;

@end

@interface VNavigationHeaderView : UIView

@property (nonatomic) BOOL showAddButton;

@property (nonatomic, weak) id<VNavigationHeaderDelegate> delegate;

+ (instancetype)menuButtonNavHeaderWithControlTitles:(NSArray *)titles;
+ (instancetype)backButtonNavHeaderWithControlTitles:(NSArray *)titles;

- (void)showHeaderLogo;
- (void)updateUI;

@end
