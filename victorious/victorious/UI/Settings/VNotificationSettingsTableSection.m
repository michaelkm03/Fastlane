//
//  VNotificationSettingsTableSection.m
//  victorious
//
//  Created by Patrick Lynch on 11/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsTableSection.h"

@implementation VNotificationSettingsTableRow

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled
{
    self = [super init];
    if (self)
    {
        _title = title;
        _isEnabled = isEnabled;
    }
    return self;
}

@end

@implementation VNotificationSettingsTableSection

- (instancetype)initWithTitle:(NSString *)title rows:(NSArray *)rows
{
    self = [super init];
    if (self)
    {
        _title = title;
        _rows = rows;
    }
    return self;
}

- (VNotificationSettingsTableRow *)rowAtIndex:(NSUInteger)index
{
    NSParameterAssert( index < self.rows.count );
    id object = self.rows[ index ];
    NSParameterAssert( [object isKindOfClass:[VNotificationSettingsTableRow class]] );
    return (VNotificationSettingsTableRow *)object;
}

@end