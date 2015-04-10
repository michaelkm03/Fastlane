//
//  VNotificationCell.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationCell.h"
#import "NSDate+timeSince.h"
#import "VThemeManager.h"
#import "VNotification+RestKit.h"
#import "VUser+RestKit.h"
#import "VDefaultProfileImageView.h"
#import "VTagStringFormatter.h"

@interface VNotificationCell ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet VDefaultProfileImageView *notificationWho;

@end

@implementation VNotificationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    self.dateLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];    
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [self.notification.isRead boolValue] ? [UIColor whiteColor] : [UIColor colorWithWhite:0.75 alpha:1.0];
}

- (void)setNotification:(VNotification *)notification
{
    _notification = notification;
    
    [self.notificationWho setProfileImageURL:[NSURL URLWithString:notification.imageURL]];
    self.accessoryType = [self.notification.deeplink length] > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:notification.body];
    NSDictionary *stringAttributes = @{ NSFontAttributeName : self.messageLabel.font };
    [VTagStringFormatter tagDictionaryFromFormattingAttributedString:mutableAttributedString
                                             withTagStringAttributes:stringAttributes
                                          andDefaultStringAttributes:stringAttributes];
    self.messageLabel.text = mutableAttributedString.string;
    self.dateLabel.text = [notification.createdAt timeSince];
    
    if ([notification.deeplink length] > 0)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

@end
