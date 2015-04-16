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
#import "VDefaultProfileButton.h"
#import "VDependencyManager.h"
#import "VTagStringFormatter.h"
#import "VUserProfileViewController.h"

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
    self.backgroundColor = [self.notification.isRead boolValue] ? [UIColor whiteColor] : [UIColor colorWithWhite:0.75 alpha:1.0];
}

- (void)setNotification:(VNotification *)notification
{
    _notification = notification;
    
    [self.notificationWho setProfileImageURL:[NSURL URLWithString:_notification.imageURL] forState:UIControlStateNormal];
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
    }
}

- (IBAction)profileButtonAction:(id)sender
{
    VUser *user = self.notification.user;
    
    //Check for nil user to avoid trying to navigate to create a profile with a nil user
    if ( user != nil )
    {
        VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:self.notification.user];
        [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.notificationWho setup];
}

@end
