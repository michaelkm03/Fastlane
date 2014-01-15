//
//  VFeaturedStreamsViewController.m
//  victoriOS
//
//  Created by David Keegan on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VFeaturedStreamsViewController.h"
#import "VFeaturedViewController.h"
#import "VSequence+RestKit.h"
#import "VSequence+Fetcher.h"
#import "VConstants.h"

static NSString* kStreamCache = @"StreamCache";

@interface VFeaturedStreamsViewController ()
<NSFetchedResultsControllerDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong) NSArray *viewControllers;
@end

@implementation VFeaturedStreamsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
    if (![self.fetchedResultsController performFetch:&error] && error)
    {
        // Update to handle the error appropriately.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];

    __block CGRect frame = self.scrollView.bounds;
    @synchronized(self.viewControllers){
        [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *stop){
            viewController.view.frame = frame;
            [self.scrollView addSubview:viewController.view];
            frame.origin.x += CGRectGetWidth(self.scrollView.bounds);
        }];
        self.scrollView.contentSize = CGSizeMake(CGRectGetMinX(frame), CGRectGetHeight(frame));
    };
}

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;

        NSFetchRequest *fetchRequest = [self fetchRequestForContext:context];

        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                            managedObjectContext:context
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:kStreamCache];
        self.fetchedResultsController.delegate = self;
    }

    return _fetchedResultsController;
}

- (NSFetchRequest*)fetchRequestForContext:(NSManagedObjectContext*)context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[VSequence entityName] inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"category == %@", kFeaturedCategory]];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:5];

    return fetchRequest;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [controller.fetchedObjects count] > 5 ? 5 : [controller.fetchedObjects count];

    NSMutableArray *viewControllers = [NSMutableArray arrayWithCapacity:self.pageControl.numberOfPages];
    for(NSUInteger i = 0; i < self.pageControl.numberOfPages && i < [controller.fetchedObjects count]; ++i)
    {
        VFeaturedViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"featured"];
        viewController.sequence = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [self addChildViewController:viewController];
        [viewController didMoveToParentViewController:self];
        [viewControllers addObject:viewController];
    }
    self.viewControllers = [viewControllers copy];
    [self.view setNeedsLayout];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = round(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds));
}

@end
