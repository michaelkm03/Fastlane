//
//  VContentInfoViewController.m
//  victorious
//
//  Created by Will Long on 7/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentInfoViewController.h"

#import "VReposterTableViewController.h"

#import "VSequence+Fetcher.h"
#import "VUser.h"

#import "VThemeManager.h"
#import "VObjectManager+Sequence.h"
#import "VConstants.h"

typedef NS_ENUM(NSUInteger, VContentCountType) {
    VRemixCountInfo = 0,
    VRepostCountInfo,
    VCommentCountInfo
};

@interface VContentInfoViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel* nameLabel;
@property (nonatomic, weak) IBOutlet UILabel* createdByLabel;

@property (nonatomic, weak) IBOutlet UIImageView* profileImageView;
@property (nonatomic, weak) IBOutlet UIImageView* backgroundImageView;

@property (nonatomic, weak) IBOutlet UIButton* reportButton;

@property (nonatomic, weak) IBOutlet UITableView* tableView;

@end

@implementation VContentInfoViewController

- (id)init
{
    UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    self = (VContentInfoViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kContentInfoStoryboardID];
    [self view];//Initialize all the IBOutlets
    
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIView animateWithDuration:0.0f animations:^
     {
         [self.view updateConstraints];
     }
                     completion:^(BOOL finished)
    {
        self.mediaContainerView.hidden = CGRectIntersectsRect(self.mediaContainerView.frame, self.tableView.frame);
    }];
    
    UIColor* secondaryLinkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor];
    
    self.nameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.nameLabel.textColor = secondaryLinkColor;
    
    self.reportButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVParagraphFont];
    self.reportButton.titleLabel.text = NSLocalizedString(@"Report/Flag", nil);
    
    self.createdByLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.createdByLabel.textColor = secondaryLinkColor;
    self.createdByLabel.text = NSLocalizedString(@"CreatedBy", nil);
    
    self.backgroundImageView.image = self.backgroundImage;
    self.sequence = self.sequence;
    
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.layer.borderWidth = 2.0;
    self.profileImageView.layer.borderColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVAccentColor].CGColor;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:YES animated:NO];
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
    
    [self.tableView reloadData];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case VRemixCountInfo:
            if ([self.sequence isPoll])
                return 0;
            
        default:
            return self.tableView.rowHeight;
            break;
    };
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"contentinfo"];
    cell.clipsToBounds = YES;
    
    NSMutableAttributedString* attributedText;
    NSInteger countLength;
    UIImage* image;
    
    switch (indexPath.row)
    {
        case VRemixCountInfo:
            image = [UIImage imageNamed:@"infoRemixIcon"];
            countLength = self.sequence.remixCount.stringValue.length;
            attributedText = [[NSMutableAttributedString alloc] initWithString: [[self.sequence.remixCount.stringValue stringByAppendingString:@" "]
                                                                                 stringByAppendingString:NSLocalizedString(@"remixes", nil)]];
            break;
            
        case VRepostCountInfo:
            image = [UIImage imageNamed:@"infoRepostIcon"];
            countLength = self.sequence.repostCount.stringValue.length;
            attributedText = [[NSMutableAttributedString alloc] initWithString: [[self.sequence.repostCount.stringValue stringByAppendingString:@" "]
                                                                                 stringByAppendingString:NSLocalizedString(@"reposts", nil)]];
            break;
            
        case VCommentCountInfo:
            image = [UIImage imageNamed:@"infoCommentIcon"];
            countLength = self.sequence.commentCount.stringValue.length;
            attributedText = [[NSMutableAttributedString alloc] initWithString: [[self.sequence.commentCount.stringValue stringByAppendingString:@" "]
                                                                                 stringByAppendingString:NSLocalizedString(@"comments", nil)]];
            break;
            
            
        default:
            countLength = 0;
            break;
    };
    
    [attributedText addAttribute:NSForegroundColorAttributeName value: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]
                           range:NSMakeRange(0, countLength)];
    
    [attributedText addAttribute:NSForegroundColorAttributeName value: [[VThemeManager sharedThemeManager] themedColorForKey:kVSecondaryLinkColor]
                           range:NSMakeRange(countLength, attributedText.length - countLength)];
    
    [attributedText addAttribute:NSFontAttributeName value:[[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font]
                           range:NSMakeRange(0, attributedText.length)];
    
    [cell.textLabel setAttributedText:attributedText];
    cell.imageView.image = image;
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row)
    {
        case VRemixCountInfo:
            break;
            
        case VRepostCountInfo:
            [self pressedReposts:nil];
            break;
            
        case VCommentCountInfo:
            [self pressedComment:nil];
            break;
            
        default:
            break;
    };
  
}

#pragma mark - Actions

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
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressedComment:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willCommentFromInfo)])
        [self.delegate willCommentFromInfo];
}

- (IBAction)pressedReposts:(id)sender
{
    VReposterTableViewController* vc = [[VReposterTableViewController alloc] init];
    vc.sequence = self.sequence;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
