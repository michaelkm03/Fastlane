//
//  VNotificationSettingsTableRow.h
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VNotificationSettingsTableRow : NSObject

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled key:(NSString *) key;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) NSString *key;

@end