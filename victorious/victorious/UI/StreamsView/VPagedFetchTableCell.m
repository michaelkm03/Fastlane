//
//  VPagedFetchTableCell.m
//  victorious
//
//  Created by Will Long on 1/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPagedFetchTableCell.h"
#import "VConstants.h"

@interface VPagedFetchTableCell() <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController* fetchedResultsController;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation VPagedFetchTableCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    __block CGRect frame = self.scrollView.bounds;
    
    @synchronized(self.pageViews)
    {
        [self.pageViews enumerateObjectsUsingBlock:^(UITableView *tableView, NSUInteger idx, BOOL *stop)
         {
             tableView.frame = frame;
             [self.scrollView addSubview:tableView];
             frame.origin.x += CGRectGetWidth(self.scrollView.bounds);
         }];
        self.scrollView.contentSize = CGSizeMake(CGRectGetMinX(frame), CGRectGetHeight(frame));
    };
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = round(scrollView.contentOffset.x/CGRectGetWidth(scrollView.bounds));
}

#pragma mark - NSFetchedResultsController

- (void)performFetch
{
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    [context performBlockAndWait:^()
     {
         NSError *error;
         if (![self.fetchedResultsController performFetch:&error] && error)
         {
             // Update to handle the error appropriately.
             NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
         }
         [self controllerDidChangeContent:self.fetchedResultsController];
     }];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (nil == _fetchedResultsController)
    {
        RKObjectManager* manager = [RKObjectManager sharedManager];
        NSManagedObjectContext *context = manager.managedObjectStore.persistentStoreManagedObjectContext;
        
        NSFetchRequest *fetchRequest = [self fetchRequest];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:fetchRequest
                                         managedObjectContext:context
                                         sectionNameKeyPath:nil
                                         cacheName: [kVPagedFetchCache stringByAppendingString: fetchRequest.entityName ?: @"" ]];
        
        self.fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (NSFetchRequest*)fetchRequest
{
    return nil;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = [controller.fetchedObjects count] > 5 ? 5 : [controller.fetchedObjects count];
    
    NSMutableArray *newViews = [[NSMutableArray alloc] init];
    for(NSUInteger i = 0; i < self.pageControl.numberOfPages && i < [controller.fetchedObjects count]; ++i)
    {
        UIView* view = [self viewForFetchedObject:[controller objectAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]]];
    
        [newViews addObject:view];
    }
    self.pageViews = [newViews copy];
    [self setNeedsLayout];
    
    [self.parentTableViewController.tableView reloadData];
}

- (UIView*) viewForFetchedObject:(id)object
{
    return nil;
}

@end
