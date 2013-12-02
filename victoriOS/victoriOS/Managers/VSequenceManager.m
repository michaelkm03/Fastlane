//
//  VSequenceManager.m
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import "VSequenceManager.h"
#import "VCategory+RestKit.h"

@implementation VSequenceManager

+(void)loadSequenceCategories
{
    RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                         appropriateObjectRequestOperationWithObject:nil
                                                         method:RKRequestMethodGET
                                                         path:@"/api/sequence/categories"
                                                         parameters:nil];
    
    [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                      RKMappingResult *mappingResult)
     {
         RKLogInfo(@"Load collection of Articles: %@", mappingResult.array);
         [self loadSequencesForAllCategories];
     } failure:^(RKObjectRequestOperation *operation, NSError *error)
     {
         RKLogError(@"Operation failed with error: %@", error);
     }];
    
    [requestOperation start];
}

+(void)loadSequencesForAllCategories
{
    NSArray* categories = [VCategory findAllObjects];
    
    __block int launched = [categories count];
    __block int returned = 0;
    
    for (VCategory* category in categories)
    {
        NSString* path = [NSString stringWithFormat:@"%@/%@", @"/api/sequence/list_by_category", category.name];
        RKManagedObjectRequestOperation* requestOperation = [[RKObjectManager sharedManager]
                                                             appropriateObjectRequestOperationWithObject:nil
                                                             method:RKRequestMethodGET
                                                             path:path
                                                             parameters:nil];
        
        
        [requestOperation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation,
                                                          RKMappingResult *mappingResult)
         {
             RKLogInfo(@"Load collection of Articles: %@", mappingResult.array);
             returned++;
             
             if(returned == launched)
             {
                 //todo: send out message to tell app we're loaded
             }
             
         } failure:^(RKObjectRequestOperation *operation, NSError *error)
         {
             RKLogError(@"Operation failed with error: %@", error);
             returned++;
             
             if(returned == launched)
             {
                 //todo: send out message to tell app we're loaded
             }
         }];
        
        [requestOperation start];
    }
}

@end
