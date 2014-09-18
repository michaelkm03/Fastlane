//
//  VStream+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream+Fetcher.h"

#import "VSequence.h"
#import "VObjectManager.h"
#import "VUser.h"

@implementation VStream (Fetcher)

+ (VStream *)remixStreamForSequence:(VSequence *)sequence
{
    NSString *apiPath = [@"/api/sequence/remixes_by_sequence/" stringByAppendingString: sequence.remoteId.stringValue ?: @"0"];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForUser:(VUser *)user
{
    NSString *apiPath = [@"/api/sequence/detail_list_by_user/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForCategories:(NSArray *)categories
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *categoryString = [categories componentsJoinedByString:@","];
    NSString *apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)hotSteamForSteamName:(NSString *)streamName
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/hot_detail_list_by_stream/" stringByAppendingString: streamName];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForHashTag:(NSString *)hashTag
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/detail_list_by_hashtag/" stringByAppendingString: hashTag];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)followerStreamForStreamName:(NSString *)streamName user:(VUser *)user
{
    user = user ?: [VObjectManager sharedManager].mainUser;
    
    NSString *apiPath = [@"/api/sequence/follows_detail_list_by_stream/" stringByAppendingString: user.remoteId.stringValue];
    apiPath = [apiPath stringByAppendingPathComponent:streamName];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForPath:(NSString *)apiPath
           managedObjectContext:(NSManagedObjectContext *)context
{
    static NSCache *streamCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      streamCache = [[NSCache alloc] init];
                  });
    
    VStream *object = [streamCache objectForKey:apiPath];
    if (object)
    {
        return object;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Stream"];
    NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"%K == %@", @"apiPath", apiPath];
    [request setPredicate:idFilter];
    NSError *error = nil;
    object = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
    }
    
    if (object)
    {
        [streamCache setObject:object forKey:apiPath];
    }
    else
    {
        //Create a new one if it doesn't exist
        object = [NSEntityDescription insertNewObjectForEntityForName:@"Stream"
                                               inManagedObjectContext:context];
        object.apiPath = apiPath;
        [object.managedObjectContext saveToPersistentStore:nil];
        
        [streamCache setObject:object forKey:apiPath];
    }
    
    return object;
}

@end
