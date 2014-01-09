//
//  VStreamsTableViewController.m
//  victoriOS
//
//  Created by goWorld on 12/2/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VStreamsTableViewController.h"
#import "VStreamsSubViewController.h"
#import "VSequence.h"
#import "UIImageView+AFNetworking.h"
#import "VObjectManager+Sequence.h"
#import "VFeaturedStreamsViewController.h"

#import "VMenuViewController.h"
#import "VMenuViewControllerTransition.h"

#import "VStreamsTableViewController+Protected.h"

#import "VCategory+Fetcher.h"
#import "UIActionSheet+BBlock.h"
#import "BBlock.h"
#import "VCreateViewController.h"
#import "VCreatePollViewController.h"

typedef NS_ENUM(NSInteger, VStreamScope)
{
    VStreamFilterAll = 0,
    VStreamFilterImages,
    VStreamFilterVideos,
    VStreamFilterVideoForums,
    VStreamFilterPolls
};

@interface VStreamsTableViewController ()
<VCreateSequenceDelegate>
@property (nonatomic, strong) VFeaturedStreamsViewController* featuredStreamsViewController;

@end

@implementation VStreamsTableViewController

+ (instancetype)sharedStreamsTableViewController
{
    static  VStreamsTableViewController*   streamsTableViewController;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        streamsTableViewController = (VStreamsTableViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: @"streams"];
    });

    return streamsTableViewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
        self.scopeType = VStreamFilterAll;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.featuredStreamsViewController =   [self.storyboard instantiateViewControllerWithIdentifier:@"featured_pages"];

    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(displaySearchBar:)];
    
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(addButtonAction:)];
    
    self.navigationItem.rightBarButtonItems= @[addButtonItem, searchButtonItem];
}

- (IBAction)addButtonAction:(id)sender
{
    BBlockWeakSelf wself = self;
    NSString *videoTitle = NSLocalizedString(@"Post Video", @"Post video button");
    NSString *photoTitle = NSLocalizedString(@"Post Photo", @"Post photo button");
    NSString *pollTitle = NSLocalizedString(@"Post Poll", @"Post poll button");
    UIActionSheet *actionSheet =
    [[UIActionSheet alloc]
     initWithTitle:nil delegate:nil
     cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
     destructiveButtonTitle:nil otherButtonTitles:videoTitle, photoTitle, pollTitle, nil];
    [actionSheet setCompletionBlock:^(NSInteger buttonIndex, UIActionSheet *actionSheet)
     {
         if(actionSheet.cancelButtonIndex == buttonIndex)
         {
             return;
         }

         if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:videoTitle])
         {
             VCreateViewController *createViewController =
             [[VCreateViewController alloc] initWithType:VCreateViewControllerTypeVideo andDelegate:self];
             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:photoTitle])
         {
             VCreateViewController *createViewController =
             [[VCreateViewController alloc] initWithType:VCreateViewControllerTypePhoto andDelegate:self];
             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
         else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:pollTitle])
         {
             VCreatePollViewController *createViewController = [[VCreatePollViewController alloc] initWithDelegate:self];
             [wself presentViewController:[[UINavigationController alloc] initWithRootViewController:createViewController] animated:YES completion:nil];
         }
     }];
    [actionSheet showInView:self.view];
}

#pragma mark - Table view data source
- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
    forFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    VSequence *info = [fetchedResultsController objectAtIndexPath:theIndexPath];
    [((VStreamViewCell*)theCell) setSequence:info];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = (VSequence*)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if ([sequence isPoll])
        return 344;
    
    if ([sequence isVideo])
        return 310;

    return 450;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VStreamViewCell *cell = [self tableView:tableView streamViewCellForIndex:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath
        forFetchedResultsController:[self fetchedResultsControllerForTableView:tableView]];

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), [self tableView:tableView heightForHeaderInSection:section]);
    UIView* containerView = [[UIView alloc] initWithFrame:frame];

    [self addChildViewController:self.featuredStreamsViewController];
    [containerView addSubview:self.featuredStreamsViewController.view];
    [self.featuredStreamsViewController didMoveToParentViewController:self];
    self.featuredStreamsViewController.view.frame = frame;

    return containerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier: @"toStreamDetails"
                              sender: [tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[VMenuViewController class]])
    {
        VMenuViewController *menuViewController = segue.destinationViewController;
        menuViewController.transitioningDelegate =
        (id <UIViewControllerTransitioningDelegate>)[VMenuViewControllerTransitionDelegate new];
        menuViewController.modalPresentationStyle = UIModalPresentationCustom;
    } else if ([segue.identifier isEqualToString:@"toStreamDetails"])
    {
        [self prepareToStreamDetailsSegue:segue sender:sender];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillSegueNotification
                                                        object:nil];
    [super viewWillDisappear:animated];
}

#pragma mark - Segue Lifecycle
- (void)prepareToStreamDetailsSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    VStreamsSubViewController *subview = (VStreamsSubViewController *)segue.destinationViewController;
    
    VSequence *sequence = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell*)sender]];
    
    subview.sequence = sequence;
}

#pragma mark - Predicate Lifecycle
- (NSPredicate*)scopeTypePredicate
{
    NSMutableArray* allPredicates = [[NSMutableArray alloc] init];
    for (NSString* categoryName in [self categoriesForCurrentScope])
    {
        [allPredicates addObject:[self categoryPredicateForString:categoryName]];
    }
    return [NSCompoundPredicate orPredicateWithSubpredicates:allPredicates];
}

- (NSPredicate*)categoryPredicateForString:(NSString*)categoryName
{
    return [NSPredicate predicateWithFormat:@"category == %@", categoryName];
}

- (NSArray*)categoriesForCurrentScope
{
    switch (self.scopeType)
    {
        case VStreamFilterVideoForums:
            return [self forumCategories];
            
        case VStreamFilterPolls:
            return [self pollCategories];
            
        case VStreamFilterImages:
            return [self imageCategories];
            
        case VStreamFilterVideos:
            return [self videoCategories];
            
        default:
            return [self allCategories];
    }
}

- (NSArray*)allCategories
{
    NSMutableArray* categories = [[NSMutableArray alloc] init];

    [categories addObjectsFromArray:[self imageCategories]];
    [categories addObjectsFromArray:[self pollCategories]];
    [categories addObjectsFromArray:[self videoCategories]];
    [categories addObjectsFromArray:[self forumCategories]];
    
    return [categories copy];
}

- (NSArray*)imageCategories
{
    return @[kVOwnerImageCategory, kVUGCImageCategory];
}

- (NSArray*)videoCategories
{
    return @[kVOwnerVideoCategory, kVUGCVideoCategory];
}

- (NSArray*)pollCategories
{
    return @[kVOwnerPollCategory, kVUGCPollCategory];
}

- (NSArray*)forumCategories
{
    return @[kVOwnerForumCategory, kVUGCForumCategory];
}

#pragma mark - Cell Lifecycle
- (void)registerCells
{
    [self.tableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamVideoCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamVideoCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamPollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamPollCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamPollCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamDoublePollCellIdentifier bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kStreamDoublePollCellIdentifier];
}

- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath
{
    VSequence* sequence = (VSequence*)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if ([sequence isForum])
        return [tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isPoll])
        return [tableView dequeueReusableCellWithIdentifier:kStreamPollCellIdentifier
                                               forIndexPath:indexPath];
    
    else
        return [tableView dequeueReusableCellWithIdentifier:kStreamViewCellIdentifier
                                               forIndexPath:indexPath];
}

#pragma mark - Refresh Lifecycle

- (void)refreshAction
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        exit(-1);  // Fail
    } else
    {   //TODO: there has to be a better way of doing this.
        if (![self.searchFetchedResultsController performFetch:&error])
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        } else
        {
            
            [self.refreshControl endRefreshing];
        }
    }
}

#pragma mark - VCreateSequenceDelegate

- (void)createViewController:(UIViewController *)viewController shouldPostWithMessage:(NSString *)message data:(NSData *)data mediaType:(NSString *)mediaType
{
    NSLog(@"%@", message);
}

@end
