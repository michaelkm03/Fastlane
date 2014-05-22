//
//  VAbstractCommentCellTableViewCell.m
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractCommentCell.h"

#import "VUserProfileViewController.h"
#import "VThemeManager.h"

#import "NSString+VParseHelp.h"

CGFloat const kEstimatedCommentRowWithMediaHeight  =   256.0f;
CGFloat const kEstimatedCommentRowHeight           =   86.0f;

CGFloat const kMessageLabelWidth = 214;

@implementation VAbstractCommentCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.dateLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.messageLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.nameLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    
    self.profileImageButton.clipsToBounds = YES;
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
}

+ (CGSize)frameSizeForMessageText:(NSString*)text
{
    UIFont* font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    NSDictionary *stringAttributes;
    if (!font)
        VLog(@"This is bad, where did the font go.");
    if (font)
        stringAttributes = [NSDictionary dictionaryWithObject:font forKey: NSFontAttributeName];
    
    return [text frameSizeForWidth:kMessageLabelWidth
                     andAttributes:stringAttributes];
}

- (IBAction)playVideo:(id)sender
{
    self.mpController = [[MPMoviePlayerController alloc] initWithContentURL:self.mediaUrl];
    [self.mpController prepareToPlay];
    self.mpController.view.frame = self.mediaPreview.frame;
    [self insertSubview:self.mpController.view aboveSubview:self.mediaPreview];
    [self.mpController play];
}

- (IBAction)profileButtonAction:(id)sender
{
    VUserProfileViewController* profileViewController = [VUserProfileViewController userProfileWithUser:self.user];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

@end
