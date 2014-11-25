//
//  VNotificationSettingsTableSection.h
//  victorious
//
//  Created by Patrick Lynch on 11/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VNotificationSettingsTableRow : NSObject

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, assign) BOOL isEnabled;

@end

@interface VNotificationSettingsTableSection : NSObject

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)rows;

- (VNotificationSettingsTableRow *)rowAtIndex:(NSUInteger)index;

@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) NSArray *rows;
@property (nonatomic, readonly) NSString *title;

@end