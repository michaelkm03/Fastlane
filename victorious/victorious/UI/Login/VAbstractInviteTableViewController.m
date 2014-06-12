//
//  VAbstractInviteTableViewController.m
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractInviteTableViewController.h"
#import "VThemeManager.h"

@interface VAbstractInviteTableViewController ()
@property (nonatomic, weak) IBOutlet    UIButton*       clearButton;
@property (nonatomic, weak) IBOutlet    UIButton*       selectAllButton;
@end

@implementation VAbstractInviteTableViewController

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
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.users count];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

#pragma mark - Actions

- (IBAction)clearFollows:(id)sender
{
    
}

- (IBAction)selectAllFollows:(id)sender
{
    
}

@end
