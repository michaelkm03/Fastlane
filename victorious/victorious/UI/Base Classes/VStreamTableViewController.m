//
//  VStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamTableViewController.h"

@interface VStreamTableViewController ()
@end

@implementation VStreamTableViewController

- (void)registerCells
{
    
}

- (NSPredicate*)searchPredicateForString:(NSString *)searchString
{
    return [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchString];
}

- (NSPredicate*)scopeTypePredicateForOption:(NSUInteger)searchOption
{
    return nil;
}

@end
