//
//  VNotificationSettingsTableRow.m
//  victorious
//
//  Created by Patrick Lynch on 12/1/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationSettingsTableRow.h"

@implementation VNotificationSettingsTableRow

- (instancetype)initWithTitle:(NSString *)title enabled:(BOOL)isEnabled key:(NSString *)key
{
    self = [super init];
    if (self)
    {
        _title = title;
        _isEnabled = isEnabled;
        _key = key; 
    }
    return self;
}

@end
