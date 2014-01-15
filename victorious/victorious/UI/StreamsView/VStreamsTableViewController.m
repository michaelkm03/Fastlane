//
//  VStreamsTableViewController.m
//  victoriOS
//
//  Created by goWorld on 12/2/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VStreamsTableViewController.h"
#import "VStreamsCommentsController.h"
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
#import "VThemeManager.h"

#import "VAsset.h"
#import "VObjectManager+Sequence.h"

typedef NS_ENUM(NSInteger, VStreamScope)
{
    VStreamFilterAll = 0,
    VStreamFilterImages,
    VStreamFilterVideos,
    VStreamFilterPolls,
    VStreamFilterVideoForums
};

@interface VStreamsTableViewController ()
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.featuredStreamsViewController =   [self.storyboard instantiateViewControllerWithIdentifier:@"featured_pages"];

    // TODO: if the user is the owner of the channel show both search and add

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Search"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(displaySearchBar:)];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willShareSequence:)
     name:kStreamsWillShareNotification object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(willCommentSequence:)
     name:kStreamsWillCommentNotification object:nil];
}

- (IBAction)addButtonAction:(id)sender
{
    // TODO: create posts if the user is the owner of the channel
}

#pragma mark - Table view data source
- (void)configureCell:(UITableViewCell *)theCell atIndexPath:(NSIndexPath *)theIndexPath
    forFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController
{
    VSequence *info = [fetchedResultsController objectAtIndexPath:theIndexPath];
    ((VStreamViewCell*)theCell).parentTableViewController = self;
    [((VStreamViewCell*)theCell) setSequence:info];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VSequence* sequence = (VSequence*)[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath];
    
    if ([sequence isPoll])
        return 344;

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
    if (self.featuredStreamsViewController && !self.featuredStreamsViewController.view.hidden)
        return 120;

    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (![self.featuredStreamsViewController.fetchedResultsController.fetchedObjects count])
        self.featuredStreamsViewController.view.hidden = YES;
    else
        self.featuredStreamsViewController.view.hidden = NO;
        
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
    VStreamsCommentsController *subview = (VStreamsCommentsController *)segue.destinationViewController;
    
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
    
    if ([sequence isForum]  && ![[sequence firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return [tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isPoll] && [sequence firstAsset])
        return [tableView dequeueReusableCellWithIdentifier:kStreamPollCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isPoll])
        return [tableView dequeueReusableCellWithIdentifier:kStreamDoublePollCellIdentifier
                                               forIndexPath:indexPath];

    else if ([sequence isVideo] && ![[sequence firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return [tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                               forIndexPath:indexPath];
    
    else
        return [tableView dequeueReusableCellWithIdentifier:kStreamViewCellIdentifier
                                               forIndexPath:indexPath];
}

#pragma mark - Refresh Lifecycle

- (void)refreshAction
{
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error] && error)
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } else
    {   //TODO: there has to be a better way of doing this.
        if (![self.searchFetchedResultsController performFetch:&error] && error)
        {
            // Update to handle the error appropriately.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
        else
        {
            [self.refreshControl endRefreshing];
        }
    }
}

#pragma mark - Notification

- (void)willShareSequence:(NSNotification *)notification
{
    VSequence *sequence = (VSequence *)notification.object;
    UIActivityViewController *activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:@[sequence.name] applicationActivities:nil];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed){
        [[VThemeManager sharedThemeManager] applyStyling];
    };
    [self presentViewController:activityViewController animated:YES completion:^{
        [[VThemeManager sharedThemeManager] removeStyling];
    }];
}

- (void)willCommentSequence:(NSNotification *)notification
{
    VStreamViewCell *cell = (VStreamViewCell *)notification.object;
    [self performSegueWithIdentifier:@"toStreamDetails" sender:cell];
}

#pragma mark - VCreateSequenceDelegate

- (void)createViewController:(UIViewController *)viewController
       shouldPostWithMessage:(NSString *)message
                        data:(NSData *)data
                   mediaType:(NSString *)mediaType
{
    
    if ([mediaType isEqualToString:@"png"])
    {
        [[[VObjectManager sharedManager] createImageWithName:nil description:message mediaData:data mediaUrl:nil successBlock:^(NSArray *resultObjects) {
            NSLog(@"%@", resultObjects);
        } failBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }] start];
    }
    else
    {
        [[[VObjectManager sharedManager] createVideoWithName:nil description:message mediaData:data mediaUrl:nil successBlock:^(NSArray *resultObjects) {
            NSLog(@"%@", resultObjects);
        } failBlock:^(NSError *error) {
            NSLog(@"%@", error);
        }] start];
    }
}

- (void)createViewController:(UIViewController *)viewController
  shouldPostPollWithQuestion:(NSString *)question
                 answer1Text:(NSString *)answer1Text
                 answer2Text:(NSString *)answer2Text
                  media1Data:(NSData *)media1Data
             media1Extension:(NSString *)media1Extension
                  media2Data:(NSData *)media2Data
             media2Extension:(NSString *)media2Extension
{
    [[[VObjectManager sharedManager] createPollWithName:nil description:nil question:question answer1Text:answer1Text answer2Text:answer2Text media1Data:media1Data media1Extension:media1Extension media1Url:nil media2Data:media2Data media2Extension:media2Extension media2Url:nil successBlock:^(AFHTTPRequestOperation *request, id object) {
        NSLog(@"%@", object);
    } failBlock:^(AFHTTPRequestOperation *request, NSError *error) {
        NSLog(@"%@", error);
    }] start];
}

@end
