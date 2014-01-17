//
//  VFetchedResultsTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VFetchedResultsTableViewController : UITableViewController

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, copy) NSString* entityName;
@property (nonatomic, strong) NSPredicate* predicate;
@property (nonatomic, strong) NSArray* sortDescriptors;
@property (nonatomic, assign) NSUInteger batchSize;

@property (nonatomic, copy) NSString* cellIdentifier;

- (void)registerCells;

- (void)refreshAction;

- (NSPredicate*)searchPredicateForString:(NSString *)searchString;
- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption;

@end
