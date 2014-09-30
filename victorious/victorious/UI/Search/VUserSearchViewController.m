//
//  VUserSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserSearchViewController.h"

#import "VAnalyticsRecorder.h"

#import "VNoContentView.h"
#import "VUserProfileViewController.h"

//Cells
#import "VInviteFriendTableViewCell.h"
#import "VFollowerTableViewCell.h"

#import "VUser.h"

//ObjectManager
#import "VObjectManager+DirectMessaging.h"
#import "VObjectManager+Users.h"


//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "VLoginViewController.h"
#import "VMessageContainerViewController.h"

#import "VThemeManager.h"

#import "MBProgressHUD.h"

#import "VAuthorizationViewControllerFactory.h"
#import "VObjectManager+Login.h"

@interface VUserSearchViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UIView *noResultsView;
@property (nonatomic, weak) IBOutlet UIImageView *noResultsIcon;
@property (nonatomic, weak) IBOutlet UILabel *noResultsTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *noResultsMessageLabel;

@property (nonatomic, weak) IBOutlet UITextField *searchField;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hrHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *vrWidthConstraint;
@property (nonatomic, weak) IBOutlet UIImageView *searchIconImageView;

@property (nonatomic, strong) NSArray *foundUsers;
@property (nonatomic, weak) NSTimer *typeDelay;
@property (nonatomic, assign) NSInteger charCount;
@property (nonatomic, strong) VUser *selectedUser;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)closeButtonAction:(id)sender;
- (void)runUserSearch:(id)sender;

@end

@implementation VUserSearchViewController

+ (instancetype)sharedInstance
{

    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VUserSearchViewController *userSearchViewController = (VUserSearchViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VUserSearchViewController class])];
    return userSearchViewController;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // SETUP SEARCH FIELD
    self.searchField.delegate = self;
    [self.searchField addTarget:self action:@selector(runUserSearch:) forControlEvents:UIControlEventEditingChanged];
    [self.searchField setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
    [self.searchField setTintColor:[UIColor grayColor]];
    [self.searchField sizeToFit];
    [self.searchField layoutIfNeeded];
    
    // NO RESULTS VIEW
    self.noResultsView.hidden = YES;
    self.noResultsTitleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.noResultsMessageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];

    // TABLEVIEW
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[UINib nibWithNibName:@"followerCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    self.tableView.hidden = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    // SET CHAR COUNTER
    self.charCount = 0;
    
    // SET THE SEARCH FIELD ACTIVE
    [self.searchField becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] startAppView:@"User Search"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[VAnalyticsRecorder sharedAnalyticsRecorder] finishAppView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)characterCheck:(id)sender
{
    
    self.charCount++;
    
    if (self.charCount == 3)
    {
        self.charCount = 0;
        [self runUserSearch:nil];
    }
}

- (void)typingTimerCheck:(id)sender
{
    if (self.typeDelay)
    {
        if ([self.typeDelay isValid])
        {
            [self.typeDelay invalidate];
        }
        self.typeDelay = nil;
    }
    self.typeDelay = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(runUserSearch:) userInfo:nil repeats:NO];
}

- (IBAction)closeButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)composeMessageToUser:(VUser *)profile
{
    if (![VObjectManager sharedManager].authorized)
    {
        [self presentViewController:[VAuthorizationViewControllerFactory requiredViewController] animated:YES completion:NULL];
        return;
    }
    
    VMessageContainerViewController *composeController = [VMessageContainerViewController messageViewControllerForUser:profile];
    [self.navigationController pushViewController:composeController animated:YES];
}

- (void)runUserSearch:(id)sender
{
    
    VSuccessBlock searchSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        NSSortDescriptor   *sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.foundUsers = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHaveSearchResults:self.foundUsers.count];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
        });
    };
    
    VFailBlock searchFail = ^(NSOperation *operation, NSError *error)
    {
        [self setHaveSearchResults:NO];
        self.tableView.hidden = YES;
        if (error.code)
        {
            self.foundUsers = [[NSArray alloc] init];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
        });
    };

    if ([self.searchField.text length] > 0)
    {
        [self.activityIndicatorView startAnimating];
        [[VObjectManager sharedManager] findMessagableUsersBySearchString:self.searchField.text
                                                         withSuccessBlock:searchSuccess
                                                                failBlock:searchFail];
    }
    else
    {
        self.foundUsers = [[NSArray alloc] init];
        self.tableView.hidden = YES;
        
    }
}

- (void)setHaveSearchResults:(BOOL)haveSearchResults
{
    if (!haveSearchResults)
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        if ([self.searchField.text length] > 0)
        {
            self.noResultsView.hidden = NO;
        }
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
        self.noResultsView.hidden = YES;
    }
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.foundUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VFollowerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.foundUsers[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    VUser *profile = self.foundUsers[indexPath.row];
    [self composeMessageToUser:profile];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self runUserSearch:nil];
    [self.searchField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL ans = YES;
    return ans;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

@end
