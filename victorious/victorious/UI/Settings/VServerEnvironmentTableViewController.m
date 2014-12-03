//
//  VServerEnvironmentTableViewController.m
//  victorious
//
//  Created by Josh Hinman on 5/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VEnvironment.h"
#import "VObjectManager+Environment.h"
#import "VServerEnvironmentTableViewController.h"
#import "VSessionTimer.h"
#import "UIViewController+VNavMenu.h"

@interface VServerEnvironmentTableViewController () <VNavigationHeaderDelegate>

@property (nonatomic, strong) NSArray *serverEnvironments;
@property (nonatomic, strong) VEnvironment *startingEnvironment;

@end

@implementation VServerEnvironmentTableViewController

- (void)awakeFromNib
{
    self.serverEnvironments = [VObjectManager allEnvironments];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    self.startingEnvironment = [VObjectManager currentEnvironment];
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (![self.startingEnvironment isEqual:[VObjectManager currentEnvironment]])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:VSessionTimerNewSessionShouldStart object:self];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
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
    cell.textLabel.text = [(VEnvironment *)self.serverEnvironments[indexPath.row] name];
    
    VEnvironment *environment = [VObjectManager currentEnvironment];
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
    [VObjectManager setCurrentEnvironment:self.serverEnvironments[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
