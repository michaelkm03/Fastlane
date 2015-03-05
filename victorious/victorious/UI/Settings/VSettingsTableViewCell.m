//
//  VSettingsTableViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSettingsTableViewCell.h"

@interface VSettingsTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *label;

@end

@implementation VSettingsTableViewCell

- (NSString *)settingName
{
    return self.label.text;
}

@end
