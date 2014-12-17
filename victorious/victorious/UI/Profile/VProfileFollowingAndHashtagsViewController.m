//
//  VProfileFollowingAndHashtagsViewController.m
//  victorious
//
//  Created by Lawrence Leach on 12/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProfileFollowingAndHashtagsViewController.h"
#import "VHashtagFollowingTableViewController.h"
#import "VFollowingTableViewController.h"
#import "VTabBarViewController.h"

@interface VProfileFollowingAndHashtagsViewController ()

@property (nonatomic, strong) VTabBarViewController                 *tabBarViewController;
@property (nonatomic, strong) VHashtagFollowingTableViewController  *contactsInnerViewController;
@property (nonatomic, strong) VFollowingTableViewController         *facebookInnerViewController;

@end

@implementation VProfileFollowingAndHashtagsViewController

- (void)awakeFromNib
{
    self.tabBarViewController = [[VTabBarViewController alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
