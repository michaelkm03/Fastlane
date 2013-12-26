//
//  VMenuTableViewController.m
//  victorious
//
//  Created by David Keegan on 12/25/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VMenuTableViewController.h"

@interface VMenuTableViewController ()

@end

@implementation VMenuTableViewController
- (void)viewDidLoad{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
