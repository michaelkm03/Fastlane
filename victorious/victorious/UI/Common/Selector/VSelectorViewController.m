//
//  VSelectorViewController.m
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSelectorViewController.h"
#import "VThemeManager.h"

@interface VSelectorViewController ()

@property (nonatomic, strong, readwrite) NSArray *items;
@property (nonatomic, copy) VSelectionItemConfigureCellBlock configureBlock;

@end

NSString *const kSelectorCellIdentifier = @"cell";

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
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:kSelectorCellIdentifier];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSelectorCellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    cell.textLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
    
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
