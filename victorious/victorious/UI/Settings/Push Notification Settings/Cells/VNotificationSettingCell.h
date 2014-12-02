//
//  VNotificationSettingCell.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VNotificationSettingCell;

@protocol VNotificationSettingCellDelegate <NSObject>

- (void)settingsDidUpdateFromCell:(VNotificationSettingCell *)cell;

@end

@interface VNotificationSettingCell : UITableViewCell

@property (nonatomic, readonly) BOOL value;
@property (nonatomic, weak) id<VNotificationSettingCellDelegate> delegate;

- (void)setTitle:(NSString *)title value:(BOOL)value;

@end
