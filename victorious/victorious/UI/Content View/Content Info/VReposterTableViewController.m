//
//  VReposterTableViewController.m
//  victorious
//
//  Created by Will Long on 7/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VReposterTableViewController.h"
#import "VInviteFriendTableViewCell.h"
#import "VNoContentView.h"
#import "VSequence.h"
#import "VUser.h"
#import "VUserProfileViewController.h"
#import "VDependencyManager+VUserProfile.h"
#import "VScrollPaginator.h"
#import "victorious-Swift.h"

@interface VReposterTableViewController () <VScrollPaginatorDelegate, PaginatedDataSourceDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VNoContentView *noContentView;
@property (nonatomic, strong) VScrollPaginator *scrollPaginator;
@property (nonatomic, strong) RepostersDataSource *dataSource;

@end

@implementation VReposterTableViewController

- (instancetype)initWithSequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self)
    {
        _dependencyManager = dependencyManager;
        _dataSource = [[RepostersDataSource alloc] initWithSequence:sequence dependencyManager:dependencyManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollPaginator = [[VScrollPaginator alloc] init];
    self.scrollPaginator.delegate = self;
    
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self;
    self.dataSource.delegate = self;
    [self.dataSource registerCells:self.tableView];
    
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.edgesForExtendedLayout = UIRectEdgeAll;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.title = NSLocalizedString(@"REPOSTERS", nil);
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1.0];
    
    // Removes the separaters for empty rows
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    VNoContentView *noContentView = [VNoContentView viewFromNibWithFrame:self.tableView.frame];
    noContentView.title = NSLocalizedString(@"NoRepostersTitle", @"");
    noContentView.message = NSLocalizedString(@"NoRepostersMessage", @"");
    noContentView.icon = [UIImage imageNamed:@"noRepostsIcon"];
    noContentView.dependencyManager = self.dependencyManager;
    self.noContentView = noContentView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.dataSource loadRepostersWithPageType:VPageTypeFirst];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[VTrackingManager sharedInstance] setValue:VTrackingValueReposters forSessionParameterWithKey:VTrackingKeyContext];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[VTrackingManager sharedInstance] clearValueForSessionParameterWithKey:VTrackingKeyContext];
}

#pragma mark - VScrollPaginatorDelegate

- (void)shouldLoadNextPage
{
    [self.dataSource loadRepostersWithPageType:VPageTypeNext];
}

- (void)shouldLoadPreviousPage
{
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    VUser *selectedUser = self.dataSource.visibleItems[ indexPath.row ];
    VUserProfileViewController *profileViewController = [self.dependencyManager userProfileViewControllerWithUser:selectedUser];
    NSAssert( self.navigationController != nil, @"View controller must be in a navigation controller." );
    [self.navigationController pushViewController:profileViewController animated:YES];
}

#pragma mark - PaginatedDataSourceDelegate

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didChangeStateFrom:(enum DataSourceState)oldState to:(enum DataSourceState)newState
{
    [self updateTableView];
}

- (void)paginatedDataSource:(PaginatedDataSource *)paginatedDataSource didUpdateVisibleItemsFrom:(NSOrderedSet *)oldValue to:(NSOrderedSet *)newValue
{
    [self.tableView v_applyChangeInSection:0 from:oldValue to:newValue];
}

#pragma mark - private

- (void)updateTableView
{
    self.tableView.separatorStyle = self.dataSource.visibleItems.count > 0 ? UITableViewCellSeparatorStyleSingleLine : UITableViewCellSeparatorStyleNone;
    
    switch ( [self.dataSource state] )
    {
        case DataSourceStateError:
        case DataSourceStateNoResults:
        {
            if ( self.tableView.backgroundView != self.noContentView )
            {
                self.tableView.backgroundView = self.noContentView;
                [self.noContentView resetInitialAnimationState];
                [self.noContentView animateTransitionIn];
            }
            break;
        }
            
        default:
            [UIView animateWithDuration:0.5f animations:^void
             {
                 self.tableView.backgroundView = nil;
             }];
            break;
    }
}

@end