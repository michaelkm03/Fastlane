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
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@end
@implementation VProfileViewController
{
    NSArray*            _labels;
    NSMutableArray*     _values;
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
    _values =   [[NSMutableArray alloc] initWithObjects:self.user.name ? self.user.name : @"",
                 self.user.email ? self.user.email : @"",
                 @"", nil];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (self.editing && !editing)
    {
        [self.tableView endEditing:YES];
        [[VObjectManager sharedManager] updateVictoriousWithEmail:_values[1]
                                                         password:_values[2]
                                                         username:_values[0]
                                                     successBlock:^(NSArray *resultObjects) {
                                                         VLog(@"Updated account: %@", resultObjects);
                                                     }
                                                        failBlock:^(NSError *error) {
                                                            UIAlertView*    alert   =   [[UIAlertView alloc] initWithTitle:@"Unable to update account" message:error.localizedDescription delegate:self cancelButtonTitle:@"Understood" otherButtonTitles:nil];
                                                            [alert show];
                                                        }];
    }
    [super setEditing:editing animated:animated];
    [self.tableView reloadData];
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
        aCell.textField.delegate = self;
        aCell.textField.secureTextEntry = (2 == indexPath.row);
        
        cell = aCell;
    }
    else
    {
        static NSString *cellIdentifier = @"display";
        
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = _labels[indexPath.row];
        cell.detailTextLabel.text = _values[indexPath.row];
        
        if (2 == indexPath.row)
            cell.detailTextLabel.text = @"";
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    [self.tableView scrollToRowAtIndexPath:[self cellIndexPathForField:textField] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField*)textField
{
    [_values replaceObjectAtIndex:[self cellIndexPathForField:textField].row withObject:textField.text];
}

#pragma mark - Private

- (NSIndexPath *)cellIndexPathForField:(UITextField *)textField
{
    UIView *view = textField;
    while (![view isKindOfClass:[UITableViewCell class]])
    {
        view = [view superview];
    }
    return [self.tableView indexPathForCell:(UITableViewCell *)view];
}

- (IBAction)showMenu
{
    [self.frostedViewController presentMenuViewController];
}

@end
