//
//  VNotificationCell.m
//  victorious
//
//  Created by Lawrence Leach on 8/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNotificationCell.h"
#import "NSDate+timeSince.h"
#import "VNotification.h"
#import "VUser.h"
#import "VDefaultProfileButton.h"
#import "VDependencyManager.h"
#import "VTagStringFormatter.h"
#import "VUserProfileViewController.h"
#import "VDependencyManager+VUserProfile.h"

static const CGFloat kLineSpacing = 3.0f;
static const CGFloat kMinimumLineHeight = 15.0f;
static const CGFloat kBaselineOffset = 0.5f;

@interface VNotificationCell ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet VDefaultProfileButton *notificationWho;

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
}

- (void)setNotification:(VNotification *)notification
{
    _notification = notification;
    
    self.notificationWho.user = notification.user;
    self.accessoryType = [self.notification.deepLink length] > 0 ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
    //This paragraph style causes emojis to display correctly
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = kMinimumLineHeight;
    paragraphStyle.lineSpacing = kLineSpacing;

    NSString *safeText = notification.subject == nil ? @"" : notification.subject;
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:safeText];
    NSDictionary *stringAttributes = @{ NSParagraphStyleAttributeName : paragraphStyle, NSBaselineOffsetAttributeName  : @(kBaselineOffset) };
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
        [self.messageLabel sizeToFit];
        self.notificationWho.dependencyManager = dependencyManager;
        self.notificationWho.tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (IBAction)profileButtonAction:(id)sender
{
    if ( self.delegate != nil )
    {
        [self.delegate cellDidSelectProfile:self];
    }
}

@end
