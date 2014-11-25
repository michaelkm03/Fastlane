//
//  VNotificationSettingCell.h
//  victorious
//
//  Created by Patrick Lynch on 11/24/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VNotificationSettingCellDelegate <NSObject>

- (void)userDidUpdateSettingAtIndex:(NSIndexPath *)indexPath withValue:(BOOL)value;

@end

@interface VNotificationSettingCell : UITableViewCell

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<VNotificationSettingCellDelegate> delegate;

- (void)setTitle:(NSString *)title value:(BOOL)value;

@end
