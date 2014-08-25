//
//  VSelectorViewController.m
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSelectorViewController.h"

@interface VSelectorViewController ()

@property (nonatomic, strong, readwrite) NSArray *items;
@property (nonatomic, copy) VSelectionItemConfigureCellBlock configureBlock;

@end

@implementation VSelectorViewController

+ (instancetype)selectorViewControllerWithItemsToSelectFrom:(NSArray *)items
                                         withConfigureBlock:(VSelectionItemConfigureCellBlock)configureBlock;
{
    VSelectorViewController *selectorViewController = [[VSelectorViewController alloc] initWithStyle:UITableViewStylePlain];
    selectorViewController.items = items;
    selectorViewController.configureBlock = configureBlock;
    return selectorViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"cell"];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    id itemForCell = [self.items objectAtIndex:indexPath.row];
    
    self.configureBlock(cell,itemForCell);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate vSelectorViewController:self
                             didSelectItem:[self.items objectAtIndex:indexPath.row]];
}

#pragma mark - Actions

- (void)cancel:(id)sender
{
    [self.delegate vSelectorViewControllerDidCancel:self];
}

@end
