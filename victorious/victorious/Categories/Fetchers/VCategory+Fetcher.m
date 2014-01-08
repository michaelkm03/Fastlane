//
//  VCategory+Fetcher.m
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCategory+Fetcher.h"
#import "VCategory+RestKit.h"

@implementation VCategory (Fetcher)

+ (VCategory*)fetchCategoryWithName:(NSString*)name
{
    NSManagedObjectContext *context = [RKObjectManager sharedManager].managedObjectStore.persistentStoreManagedObjectContext;
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:[VCategory entityName]
                                              inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"display_order" ascending:YES];
    [request setSortDescriptors:@[sort]];
    
    NSPredicate* nodeFilter = [NSPredicate predicateWithFormat:@"name == %@", name];
    [request setPredicate:nodeFilter];
    
    NSError *error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (error != nil)
    {
        VLog(@"Error occured in fetchCategoryWithName: %@", error);
    }
    
    return [results firstObject];//if we have multiple of the same name it doesn't matter.
}

@end
