//
//  VContentInfoViewController.m
//  victorious
//
//  Created by Will Long on 7/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentInfoViewController.h"

#import "VSequence.h"
#import "VUser.h"

#import "VThemeManager.h"
#import "VObjectManager+Sequence.h"
#import "VConstants.h"

@interface VContentInfoViewController () <UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* createdByLabel;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, weak) IBOutlet UITableViewCell* remixTableCell;
@property (nonatomic, weak) IBOutlet UITableViewCell* repostTableCell;
@property (nonatomic, weak) IBOutlet UITableViewCell* commentTableCell;

@property (nonatomic, weak) IBOutlet UIButton* reportButton;

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

@implementation VContentInfoViewController

+ (VContentInfoViewController *)sharedInstance
{
    static  VContentInfoViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken,
                  ^{
                      UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
                      sharedInstance = (VContentInfoViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentInfoStoryboardID];
                  });
    
    return sharedInstance;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIColor* secondaryLinkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.nameLabel.textColor = secondaryLinkColor;
    
    self.reportButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.reportButton.titleLabel.text = NSLocalizedString(@"Report/Flag", nil);
    
    self.createdByLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.createdByLabel.textColor = secondaryLinkColor;
    self.createdByLabel.text = NSLocalizedString(@"CreatedBy", nil);
    
    self.remixTableCell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    self.remixTableCell.textLabel.textColor = secondaryLinkColor;
    self.remixTableCell.textLabel.text = [@"0" stringByAppendingString:NSLocalizedString(@"remixes", nil)];
    
    self.repostTableCell.textLabel.font = self.remixTableCell.textLabel.font;
    self.repostTableCell.textLabel.textColor = secondaryLinkColor;
    self.repostTableCell.textLabel.text = [@"0" stringByAppendingString:NSLocalizedString(@"resposts", nil)];
    
    self.commentTableCell.textLabel.font = self.remixTableCell.textLabel.font;
    self.commentTableCell.textLabel.textColor = secondaryLinkColor;
    self.commentTableCell.textLabel.text = [@"0" stringByAppendingString:NSLocalizedString(@"comments", nil)];
    
    self.backgroundImageView.image = self.backgroundImage;
    self.sequence = self.sequence;
    
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
}

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    
    self.backgroundImageView.image = self.backgroundImage;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    self.nameLabel.text = sequence.user.name;
    [self.profileImageView setImageWithURL:[NSURL URLWithString:sequence.user.pictureUrl] placeholderImage:[UIImage imageNamed:@"profile_full"]];
    
    UIColor* secondaryLinkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    UIColor* linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];

    NSMutableAttributedString* attributedText;
    NSInteger countLength;
    
    countLength = sequence.remixCount.stringValue.length;
    attributedText = [[NSMutableAttributedString alloc] initWithString:
                      [sequence.remixCount.stringValue stringByAppendingString:NSLocalizedString(@"remixes", nil)]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:linkColor
                    range:NSMakeRange(0, countLength)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:secondaryLinkColor
                    range:NSMakeRange(countLength, attributedText.length - countLength)];
    [self.remixTableCell.textLabel setAttributedText:attributedText];
    
    countLength = sequence.commentCount.stringValue.length;
    attributedText = [[NSMutableAttributedString alloc] initWithString:
                      [sequence.commentCount.stringValue stringByAppendingString:NSLocalizedString(@"comments", nil)]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:linkColor
                           range:NSMakeRange(0, countLength)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:secondaryLinkColor
                           range:NSMakeRange(countLength, attributedText.length - countLength)];
    [self.commentTableCell.textLabel setAttributedText:attributedText];
    
    countLength = sequence.remixCount.stringValue.length;
    attributedText = [[NSMutableAttributedString alloc] initWithString:
                      [@"0" stringByAppendingString:NSLocalizedString(@"resposts", nil)]];
    [attributedText addAttribute:NSForegroundColorAttributeName value:linkColor
                           range:NSMakeRange(0, countLength)];
    [attributedText addAttribute:NSForegroundColorAttributeName value:secondaryLinkColor
                           range:NSMakeRange(countLength, attributedText.length - countLength)];
    [self.repostTableCell.textLabel setAttributedText:attributedText];
}

- (IBAction)pressedReport:(id)sender
{
    [[VObjectManager sharedManager] flagSequence:self.sequence
                                    successBlock:^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
     {
         UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                message:NSLocalizedString(@"ReportContentMessage", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
         [alert show];
         
     }
                                       failBlock:^(NSOperation* operation, NSError* error)
     {
         VLog(@"Failed to flag sequence %@", self.sequence);
         
         //TODO: we may want to remove this later.
         UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ReportedTitle", @"")
                                                                message:NSLocalizedString(@"ReportContentMessage", @"")
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                                      otherButtonTitles:nil];
         [alert show];
     }];
}

- (IBAction)pressedBack:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(didCloseFromInfo)])
        [self.delegate didCloseFromInfo];
}

- (IBAction)pressedFlip:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
