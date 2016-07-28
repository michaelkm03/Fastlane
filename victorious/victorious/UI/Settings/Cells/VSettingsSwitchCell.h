//
//  VSettingsSwitchCell.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VSettingsSwitchCell;

@protocol VSettingsSwitchCellDelegate <NSObject>

- (void)settingsDidUpdateFromCell:(VSettingsSwitchCell *)cell newValue:(BOOL)newValue key:(NSString *)key;

@end

@interface VSettingsSwitchCell : UITableViewCell <VHasManagedDependencies>

@property (nonatomic, readonly) BOOL value;
@property (nonatomic, weak, nullable) id<VSettingsSwitchCellDelegate> delegate;
@property (nonatomic, copy) UIColor *switchColor;
@property (nonatomic, strong) NSString *key;

- (void)setTitle:(NSString *)title value:(BOOL)value;

- (void)setValue:(BOOL)value animated:(BOOL)animated;

- (void)setSeparatorHidden:(BOOL)value; 

+ (NSString *)suggestedReuseIdentifier;

/**
 Provides the cell with an instance of VDependencyManager
 */
- (void)setDependencyManager:(VDependencyManager *)dependencyManager;

@end

NS_ASSUME_NONNULL_END
