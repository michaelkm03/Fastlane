//
//  VMenuController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VMenuController.h"
#import "REFrostedViewController.h"
#import "VStreamsTableViewController.h"
#import "VForumsViewController.h"
#import "VLoginViewController.h"
#import "VOwnerViewController.h"

#import "VObjectManager+Login.h"
//TODO:remove this import, need to test
#import "VObjectManager+Sequence.h"

@implementation VMenuController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor colorWithRed:150/255.0f green:161/255.0f blue:177/255.0f alpha:1.0f];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 184.0f)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40, 100, 100)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        imageView.image = [UIImage imageNamed:@"avatar.jpg"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = 50.0;
        imageView.layer.borderColor = [UIColor whiteColor].CGColor;
        imageView.layer.borderWidth = 3.0f;
        imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
        imageView.layer.shouldRasterize = YES;
        imageView.clipsToBounds = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 150, 0, 24)];
        label.text = @"Sam Rogoway";
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:17];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectionIndex
//{
//    if (sectionIndex == 0)
//        return nil;
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
//    view.backgroundColor = [UIColor colorWithRed:167/255.0f green:167/255.0f blue:167/255.0f alpha:0.6f];
//    
//    return view;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectionIndex
//{
//    if (sectionIndex == 0)
//        return 0;
//    
//    return 34;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UINavigationController *navigationController = (UINavigationController *)self.frostedViewController.contentViewController;

    if (indexPath.section == 0 && indexPath.row == 0)
    {
        VStreamsTableViewController*    streamsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"streams"];
        navigationController.viewControllers = @[streamsViewController];
        navigationController.toolbarHidden = YES;
    }
    else if (indexPath.section == 0 && indexPath.row == 1)
    {
        VForumsViewController*  forumsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"forums"];
        navigationController.viewControllers = @[forumsViewController];
        navigationController.toolbarHidden = YES;
    }
    else if (indexPath.section == 0 && indexPath.row == 2)
    {
        if (![VObjectManager sharedManager].authorized)
            [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        else
        {
            VForumsViewController*  forumsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"inbox"];
            navigationController.viewControllers = @[forumsViewController];
            navigationController.toolbarHidden = NO;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 3)
    {
        if (![VObjectManager sharedManager].authorized)
            [self presentViewController:[VLoginViewController sharedLoginViewController] animated:YES completion:NULL];
        else
        {
            VForumsViewController*  forumsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"profile"];
            navigationController.viewControllers = @[forumsViewController];
            navigationController.toolbarHidden = NO;
        }
    }
    else if (indexPath.section == 0 && indexPath.row == 4)
    {
        if ([VObjectManager sharedManager].isOwner)
        {
            VOwnerViewController*   ownerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"owner"];
            navigationController.viewControllers = @[ownerViewController];
            navigationController.toolbarHidden = NO;
        } else
        {
            VLog(@"Warning: Non-owner user is attempting to access the ownerview");
        }
    }
    if (indexPath.section == 1 && indexPath.row == 0)
    {
        if([VObjectManager sharedManager].authorized)
        {
            [[[VObjectManager sharedManager] logout] start];
        }
    }
    
    [self.frostedViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (0 == sectionIndex)
    {
        if ([VObjectManager sharedManager].isOwner)
            return 5;
        else
            return 4;
    }

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (indexPath.section == 0)
    {
        if ([VObjectManager sharedManager].isOwner)
        {
            NSArray *titles = @[@"Streams", @"Forums", @"Inbox", @"Profile", @"Create Poll"];
            cell.textLabel.text = titles[indexPath.row];
       }
        else
        {
            NSArray *titles = @[@"Streams", @"Forums", @"Inbox", @"Profile"];
            cell.textLabel.text = titles[indexPath.row];
        }
    }
    else
    {
        cell.textLabel.text = @"Sign out";
    }
    
    return cell;
}

@end
