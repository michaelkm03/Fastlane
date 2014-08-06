//
//  VUserSearchViewController.m
//  victorious
//
//  Created by Lawrence Leach on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VUserSearchViewController.h"

#import "NSString+URLEncode.h"
#import "VAnalyticsRecorder.h"
#import "VConstants.h"

#import "VNoContentView.h"
#import "VUserProfileViewController.h"

//Cells
#import "VInviteFriendTableViewCell.h"
#import "VUser.h"

//ObjectManager
#import "VObjectManager+Users.h"

//Data Models
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "VThemeManager.h"

#import "MBProgressHUD.h"

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
@property (nonatomic) BOOL haveSearchResults;
@property (nonatomic, weak) NSTimer *typeDelay;
@property (nonatomic, assign) NSInteger charCount;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

-(IBAction)closeButtonAction:(id)sender;
-(void)runUserSearch:(id)sender;

@end

@implementation VUserSearchViewController

+(instancetype)sharedInstance
{

    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VUserSearchViewController *userSearchViewController = (VUserSearchViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VUserSearchViewController class])];
    return userSearchViewController;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchField.delegate = self;
    //[self.searchField addTarget:self action:@selector(typingTimerCheck:) forControlEvents:UIControlEventEditingChanged];
    [self.searchField addTarget:self action:@selector(characterCheck:) forControlEvents:UIControlEventEditingChanged];
    [self.searchField setTextColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVContentTextColor]];
    [self.searchField setTintColor:[UIColor grayColor]];
    
    // NO RESULTS VIEW
    self.noResultsView.hidden = YES;
    self.noResultsTitleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.noResultsMessageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];

    // TABLEVIEW
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    [self.tableView registerNib:[UINib nibWithNibName:@"inviteCell" bundle:nil] forCellReuseIdentifier:@"followerCell"];
    self.tableView.hidden = YES;

    // SET CHAR COUNTER
    self.charCount = 0;
}

-(void)characterCheck:(id)sender
{
    
    self.charCount++;
    
    if (self.charCount == 3)
    {
        self.charCount = 0;
        [self runUserSearch:nil];
    }
}

-(void)typingTimerCheck:(id)sender
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

-(IBAction)closeButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void)runUserSearch:(id)sender
{
    [self.activityIndicatorView startAnimating];
    
    VSuccessBlock searchSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSSortDescriptor*   sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        self.foundUsers = [resultObjects sortedArrayUsingDescriptors:@[sort]];
        [self setHaveSearchResults:self.foundUsers.count];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.activityIndicatorView stopAnimating];
        });
    };
    
    VFailBlock searchFail = ^(NSOperation* operation, NSError* error)
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

    [[VObjectManager sharedManager] findUsersBySearchString:self.searchField.text
                                           withSuccessBlock:searchSuccess
                                                  failBlock:searchFail];
}

-(void)setHaveSearchResults:(BOOL)haveSearchResults
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
    VInviteFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"followerCell" forIndexPath:indexPath];
    cell.profile = self.foundUsers[indexPath.row];
    //cell.showButton = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    return nil;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self runUserSearch:nil];
    [self.searchField resignFirstResponder];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL ans = YES;

    /*
    NSLog(@"%@",string);
    if (string.length > 0)
    {
        [self characterCheck:nil];
    }
    */
    return ans;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    NSLog(@"\n\n-----\nEditing Started\n-----\n\n");
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"\n\n-----\nEditing Stopped\n-----\n\n");
    return YES;
}

@end
