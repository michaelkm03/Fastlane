//
//  VAbstractInviteTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractInviteTableViewController.h"
#import "VThemeManager.h"
#import "VInviteFriendTableViewCell.h"
#import "VNoContentView.h"
#import "VObjectManager+Users.h"

@interface VAbstractInviteTableViewController ()
@property (nonatomic, weak) IBOutlet    UIButton*       clearButton;
@property (nonatomic, weak) IBOutlet    UIButton*       selectAllButton;
@property (nonatomic, strong)           NSMutableArray* inviteState;
@end

@implementation VAbstractInviteTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        self.users = [[NSArray alloc] init];
        self.inviteState = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.clearButton.layer.borderWidth = 2.0;
    self.clearButton.layer.cornerRadius = 3.0;
    self.clearButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.clearButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    self.selectAllButton.layer.borderWidth = 2.0;
    self.selectAllButton.layer.cornerRadius = 3.0;
    self.selectAllButton.layer.borderColor = [UIColor blackColor].CGColor;
    self.selectAllButton.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVButton2Font];
    [self.tableView registerNib:[UINib nibWithNibName:@"inviteCell" bundle:nil] forCellReuseIdentifier:@"inviteCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSUInteger i = 0; i < self.users.count; i++)
        [self.inviteState addObject:@YES];
    [self refresh:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VInviteFriendTableViewCell*    cell = [tableView dequeueReusableCellWithIdentifier:@"inviteCell" forIndexPath:indexPath];
    cell.profile = self.users[indexPath.row];
    cell.delegate = self;
    NSNumber*   value = self.inviteState[indexPath.row];
    cell.shouldInvite = value.boolValue;
    return cell;
}

- (void)setHasFollowers:(BOOL)hasFollowers
{
    if (!hasFollowers)
    {
        VNoContentView* noFollowersView = [VNoContentView noContentViewWithFrame:self.tableView.frame];
        self.tableView.backgroundView = noFollowersView;
        noFollowersView.titleLabel.text = NSLocalizedString(@"NoFriends", @"");
        noFollowersView.messageLabel.text = NSLocalizedString(@"NoFriendsDetail", @"");
        noFollowersView.iconImageView.image = [UIImage imageNamed:@"noFollowersIcon"];
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    else
    {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
}

#pragma mark - Actions

- (IBAction)refresh:(id)sender
{
    BOOL    hasFollowers = ([self.users count] > 0);
    [self setHasFollowers:hasFollowers];
    if (hasFollowers)
        [self.tableView reloadData];
}

- (IBAction)clearFollows:(id)sender
{
    for (NSUInteger i = 0; i < self.inviteState.count; i++)
        self.inviteState[i] = @NO;
    [self.tableView reloadData];
}

- (IBAction)selectAllFollows:(id)sender
{
    for (NSUInteger i = 0; i < self.inviteState.count; i++)
        self.inviteState[i] = @YES;
    [self.tableView reloadData];
}

- (NSArray *)inviteList
{
    NSIndexSet* indexSet = [self.users indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop)
    {
        NSNumber*   value = self.inviteState[idx];
        return value.boolValue;
    }];
    
    return [self.users objectsAtIndexes:indexSet];
}

#pragma mark - VInviteFriendTableViewCellDelegate

- (void)cellDidSelectInvite:(VInviteFriendTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.inviteState[indexPath.row] = @YES;
}

- (void)cellDidSelectUninvite:(VInviteFriendTableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.inviteState[indexPath.row] = @NO;
}

@end
