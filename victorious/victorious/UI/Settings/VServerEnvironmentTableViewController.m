//
//  VServerEnvironmentTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"
#import "VServerEnvironmentTableViewController.h"
#import "VSessionTimer.h"
#import "VThemeManager.h"
#import "VEnvironmentManager.h"

@interface VServerEnvironmentTableViewController ()

@property (nonatomic, strong) NSArray *serverEnvironments;
@property (nonatomic, strong) VEnvironment *startingEnvironment;

@end

@implementation VServerEnvironmentTableViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.serverEnvironments = [[VEnvironmentManager sharedInstance] allEnvironments];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.automaticallyAdjustsScrollViewInsets = YES;
    self.startingEnvironment = [[VEnvironmentManager sharedInstance] currentEnvironment];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.serverEnvironments = [[VEnvironmentManager sharedInstance] allEnvironments];
    [self.tableView reloadData];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![self.startingEnvironment isEqual:[[VEnvironmentManager sharedInstance] currentEnvironment]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.serverEnvironments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const reuseID = @"serverCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID forIndexPath:indexPath];
    cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading3Font];
    cell.textLabel.text = [(VEnvironment *)self.serverEnvironments[indexPath.row] name];
    
    VEnvironment *environment = [[VEnvironmentManager sharedInstance] currentEnvironment];
    if ([environment isEqual:self.serverEnvironments[indexPath.row]])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (NSUInteger n = 0; n < self.serverEnvironments.count; n++)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:n inSection:0]];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [VEnvironmentManager sharedInstance].currentEnvironment = self.serverEnvironments[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
