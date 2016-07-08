//
//  VConversationCell.m
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationCell.h"
#import "VUserProfileViewController.h"
#import "VDefaultProfileButton.h"
#import "VConversation.h"
#import "victorious-Swift.h"

const CGFloat VConversationCellHeight = 72.0f;
static const CGFloat kLineSpacing = 3.0f;
static const CGFloat kMinimumLineHeight = 15.0f;
static const CGFloat kBaselineOffset = 0.5f;

@interface VConversationCell ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet VDefaultProfileButton *profileButton;

@end

@implementation VConversationCell

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.dateLabel.font = [UIFont fontWithName:@"MuseoSans-100" size:11.0f];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        self.messageLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
        self.usernameLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
        self.usernameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.profileButton.dependencyManager = dependencyManager;
        self.profileButton.tintColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
}

- (void)setConversation:(VConversation *)conversation
{
    _conversation = conversation;
    
    self.usernameLabel.text  = conversation.user.name;
    
    //This paragraph style causes emojis to display correctly
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.minimumLineHeight = kMinimumLineHeight;
    paragraphStyle.lineSpacing = kLineSpacing;
    
    NSString *lastMessageText = conversation.lastMessageText;
    if ( lastMessageText == nil || lastMessageText.length == 0 )
    {
        //We recieved an empty message, check if we got an image or video along with it.
        NSString *mediaType = conversation.lastMessageContentType;
        if ( mediaType != nil )
        {
            //Got a valid media type string from the backend, use that to set the text.
            lastMessageText = mediaType;
        }
        else if ( lastMessageText == nil )
        {
            //Got only an empty message, just make the string non-nil to prevent a crash.
            lastMessageText = @"";
        }
    }
    
    self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:lastMessageText attributes:@{ NSParagraphStyleAttributeName : paragraphStyle, NSBaselineOffsetAttributeName  : @(kBaselineOffset) }];
    self.dateLabel.text = [conversation.postedAt stringDescribingTimeIntervalSinceNow];
    self.profileButton.user = conversation.user;
}

- (IBAction)profileButtonAction:(id)sender
{
    if ( self.delegate != nil )
    {
        [self.delegate cellDidSelectProfile:self];
    }
}

@end
