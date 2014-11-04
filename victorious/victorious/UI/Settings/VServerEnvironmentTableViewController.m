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

#import "UIViewController+VNavMenu.h"

@interface VServerEnvironmentTableViewController () <VNavigationHeaderDelegate>

@property (nonatomic, strong) NSArray *serverEnvironments;

@end

@implementation VServerEnvironmentTableViewController

- (void)awakeFromNib
{
    self.serverEnvironments = [VObjectManager allEnvironments];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.parentViewController v_addNewNavHeaderWithTitles:nil];
    self.parentViewController.navHeaderView.delegate = (UIViewController<VNavigationHeaderDelegate> *)self.parentViewController;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please restart the app for this change to take effect." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
