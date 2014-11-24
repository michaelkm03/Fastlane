//
//  VNotificationSettingsViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VNotificationSettingsSection : NSObject

- (instancetype)initWithTitle:(NSString *)title data:(NSArray *)data;

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSArray *data;
@property (nonatomic, readonly) NSString *title;

@end

@interface VNotificationSetting : NSObject

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BOOL isEnabled;

@end

@interface VNotificationSettingsViewController : UITableViewController

@end
