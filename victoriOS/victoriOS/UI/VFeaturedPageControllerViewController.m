//
//  VFeaturedPageControllerViewController.m
//  victoriOS
//
//  Created by Gary Philipp on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VFeaturedPageControllerViewController.h"
#import "VFeaturedViewController.h"
#import "VSequence.h"

static NSString* kStreamCache = @"StreamCache";

@interface VFeaturedPageControllerViewController ()
<NSFetchedResultsControllerDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@end

@implementation VFeaturedPageControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSError *error;
	if (![self.fetchedResultsController performFetch:&error])
    {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.view.frame = self.view.superview.bounds;
}

#pragma mark - UIPageViewControllerDelegate

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    return viewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    return viewController;
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Sequence" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];

    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [fetchRequest setSortDescriptors:@[sort]];
    [fetchRequest setFetchBatchSize:50];

    return fetchRequest;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    VSequence *sequence = [[controller fetchedObjects] firstObject];
    VFeaturedViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"featured"];
    [viewController.imageView setImageWithURL:[NSURL URLWithString:sequence.previewImage]
                             placeholderImage:[UIImage new]];
    [self setViewControllers:@[viewController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES completion:nil];
}

@end
