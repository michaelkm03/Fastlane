//
//  VFindFriendsTableView.m
//  victorious
//
//  Created by Josh Hinman on 6/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VActivityIndicatorView.h"
#import "VFindFriendsTableView.h"
#import "VThemeManager.h"

@interface VFindFriendsTableView ()

@property (nonatomic, weak) IBOutlet UILabel                *connectPromptLabel;
@property (nonatomic, weak) IBOutlet VActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IBOutlet UIView               *safetyInfoView;
@property (nonatomic, strong) IBOutlet UILabel              *safetyInfoLabel;

@end

@implementation VFindFriendsTableView

+ (VFindFriendsTableView *)newFromNibWithOwner:(VFindFriendsTableViewController *)nibOwner
{
    UINib *findFriendsNib = [UINib nibWithNibName:@"FindFriendsTableView" bundle:nil];
    NSArray *nibContents = [findFriendsNib instantiateWithOwner:nibOwner options:nil];
    for (id object in nibContents)
    {
        if ([object isKindOfClass:[VFindFriendsTableView class]])
        {
            return object;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    [self.activityIndicator startAnimating];
    self.errorLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
    self.connectButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.connectButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.retryButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.retryButton.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.clearButton.layer.borderColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] CGColor];
    self.clearButton.layer.borderWidth = 1.5f;
    self.clearButton.layer.cornerRadius = 3.0f;
    self.selectAllButton.layer.borderColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] CGColor];
    self.selectAllButton.layer.borderWidth = 1.5f;
    self.selectAllButton.layer.cornerRadius = 3.0f;

    self.inviteFriendsButton.layer.borderColor = [[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f] CGColor];
    self.inviteFriendsButton.layer.borderWidth = 1.5f;
    self.inviteFriendsButton.layer.cornerRadius = 3.0f;
}

- (void)setConnectPromptLabelText:(NSString *)text
{
    self.connectPromptLabel.attributedText = [[NSAttributedString alloc] initWithString:[text uppercaseStringWithLocale:[NSLocale currentLocale]] attributes:[self connectPromptLabelTextAttributes]];
}

- (NSDictionary *)connectPromptLabelTextAttributes
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.minimumLineHeight = 30.0f;
    paragraph.maximumLineHeight = 30.0f;
    paragraph.alignment = NSTextAlignmentCenter;
    return @{ NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont] };
}

- (void)setSafetyInfoLabelText:(NSString *)text
{
    self.safetyInfoLabel.attributedText = [[NSAttributedString alloc] initWithString:text attributes:[self safetyInfoLabelTextAttributes]];
}

- (NSDictionary *)safetyInfoLabelTextAttributes
{
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.minimumLineHeight = 15.0f;
    paragraph.maximumLineHeight = 15.0f;
    paragraph.alignment = NSTextAlignmentCenter;
    NSDictionary *attributeDictionary = @{
                                          NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryAccentColor],
                                          NSParagraphStyleAttributeName: paragraph, NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font]
                                          };
    return attributeDictionary;
}

@end
