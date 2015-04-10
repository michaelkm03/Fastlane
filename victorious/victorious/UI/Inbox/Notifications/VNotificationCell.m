//
//  VNotificationCell.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationCell.h"
#import "NSDate+timeSince.h"
#import "VNotification+RestKit.h"
#import "VUser+RestKit.h"
#import "VDefaultProfileImageView.h"
#import "VDependencyManager.h"
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
    self.accessoryType = [self.notification.deepLink length] > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = 17.0f;
    paragraphStyle.maximumLineHeight = 17.0f;

    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:notification.body];
    NSDictionary *stringAttributes = @{ NSParagraphStyleAttributeName : paragraphStyle };
    [VTagStringFormatter tagDictionaryFromFormattingAttributedString:mutableAttributedString
                                             withTagStringAttributes:stringAttributes
                                          andDefaultStringAttributes:stringAttributes];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:mutableAttributedString.string attributes:stringAttributes];
    self.messageLabel.attributedText = attributedString;

    self.dateLabel.text = [notification.createdAt timeSince];
    
    if ([notification.deepLink length] > 0)
    {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else
    {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( _dependencyManager != nil )
    {
        self.messageLabel.font = [_dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
    }
}

@end
