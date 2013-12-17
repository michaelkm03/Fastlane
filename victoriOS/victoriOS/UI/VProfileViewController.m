//
//  VProfileViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VProfileViewController.h"
#import "REFrostedViewController.h"
#import "VObjectManager+Login.h"
#import "VUser.h"
#import "VProfileEditCell.h"

@interface      VProfileViewController  ()
@property (strong, nonatomic) IBOutlet UIBarButtonItem *signoutButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@end
@implementation VProfileViewController
{
    NSArray*    _labels;
    NSArray*    _values;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.userIsLoggedInUser)
    {
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        self.navigationController.toolbarHidden = YES;
     
        self.user = [VObjectManager sharedManager].mainUser;
    }
    else
    {
        self.navigationController.toolbarHidden = NO;
    }

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
        label.text = self.user.name;
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor colorWithRed:62/255.0f green:68/255.0f blue:75/255.0f alpha:1.0f];
        [label sizeToFit];
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        [view addSubview:imageView];
        [view addSubview:label];
        view;
    });
    
    _labels =   @[@"Name", @"E-Mail", @"Password"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
    
    if (!editing)
    {
        //  commit values
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell*    cell    =   nil;

    if (self.editing)
    {
        static NSString *cellIdentifier = @"edit";
        
        VProfileEditCell*   aCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        aCell.textLabel.text = _labels[indexPath.row];
        
        switch (indexPath.row)
        {
            case 0:
                aCell.textField.text = self.user.name;
                break;
                
            case 1:
                aCell.textField.text = self.user.email;
                break;
                
            case 2:
                aCell.textField.text = @"";
                aCell.textField.secureTextEntry = YES;
                break;
        }
        
        cell = aCell;
    }
    else
    {
        static NSString *cellIdentifier = @"display";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = _labels[indexPath.row];
        
        switch (indexPath.row)
        {
            case 0:
                cell.detailTextLabel.text = self.user.name;
                break;
                
            case 1:
                cell.detailTextLabel.text = self.user.email;
                break;
                
            case 2:
                cell.detailTextLabel.text = @"••••••••";
                break;
        }
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

@end
