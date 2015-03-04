//
//  VStream+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStream+Fetcher.h"
#import "VStream+RestKit.h"

#import "VSequence.h"
#import "VObjectManager.h"
#import "VThemeManager.h"
#import "VUser.h"

NSString * const VStreamFollowerStreamPath = @"/api/sequence/follows_detail_list_by_stream/";

NSString * const VStreamFilterTypeRecent = @"recent";
NSString * const VStreamFilterTypePopular = @"popular";

@implementation VStream (Fetcher)

- (BOOL)isHashtagStream
{
    return self.hashtag != nil;
}

+ (VStream *)remixStreamForSequence:(VSequence *)sequence
{
    NSString *apiPath = [@"/api/sequence/remixes_by_sequence/" stringByAppendingString: sequence.remoteId ?: @"0"];
    return [self streamForPath:apiPath inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForUser:(VUser *)user
{
    NSString *apiPath = [@"/api/sequence/detail_list_by_user/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    return [self streamForPath:apiPath inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForCategories:(NSArray *)categories
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *categoryString = [categories componentsJoinedByString:@","];
    NSString *apiPath = [@"/api/sequence/detail_list_by_category/" stringByAppendingString: categoryString ?: @"0"];
    VStream *stream = [self streamForPath:apiPath inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.name = NSLocalizedString(@"Recent", nil);
    return stream;
}

+ (VStream *)hotSteamForSteamName:(NSString *)streamName
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/hot_detail_list_by_stream/" stringByAppendingString: streamName];
    VStream *stream = [self streamForPath:apiPath inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.name = NSLocalizedString(@"Featured", nil);
    return stream;
}

+ (VStream *)streamForHashTag:(NSString *)hashTag
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/detail_list_by_hashtag/" stringByAppendingString: hashTag];
    NSManagedObjectContext *context = [[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext];
    VStream *stream = [self streamForPath:apiPath inContext:context];
    stream.hashtag = hashTag;
    stream.name = [@"#" stringByAppendingString:hashTag];
    return stream;
}

+ (VStream *)followerStreamForStreamName:(NSString *)streamName user:(VUser *)user
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");

    user = user ?: [VObjectManager sharedManager].mainUser;
    
    NSString *apiPath = [@"/api/sequence/follows_detail_list_by_stream/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    apiPath = [apiPath stringByAppendingPathComponent:streamName];
    VStream *stream = [self streamForPath:apiPath inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.name = NSLocalizedString(@"Following", nil);
    return stream;
}

+ (VStream *)streamForChannelsDirectory
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    
    VStream *directory =  [self streamForRemoteId:@"directory"
                                       filterName:nil
                             managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    
    directory.name = NSLocalizedString(@"Channels", nil);
    [directory.managedObjectContext saveToPersistentStore:nil];
    return directory;
}

+ (VStream *)streamForMarqueeInContext:(NSManagedObjectContext *)context
{
    return [self streamForRemoteId:@"marquee" filterName:@"0" managedObjectContext:context];
}

+ (VStream *)streamForRemoteId:(NSString *)remoteId
                    filterName:(NSString *)filterName
          managedObjectContext:(NSManagedObjectContext *)context
{
    NSString *streamIdKey = remoteId ?: @"0";
    NSString *filterIdKey;
    NSString *apiPath = [@"/api/sequence/detail_list_by_stream/" stringByAppendingPathComponent:streamIdKey];
    if (filterName.length)
    {
        filterIdKey = filterName;
        apiPath = [apiPath stringByAppendingPathComponent:filterIdKey];
    }
    
    VStream *stream = [self streamForPath:apiPath inContext:context];
    stream.remoteId = remoteId;
    stream.filterName = filterName;
    [stream.managedObjectContext saveToPersistentStore:nil];
    return stream;
}

+ (VStream *)streamForPath:(NSString *)apiPath
                 inContext:(NSManagedObjectContext *)context
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
        if (object.managedObjectContext != context)
        {
            // If the contexts don't match, release the safety valve: dump all the chached objects and re-create them.
            [streamCache removeAllObjects];
        }
        else
        {
            return object;
        }
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VStream entityName]];
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
        object = [NSEntityDescription insertNewObjectForEntityForName:[VStream entityName]
                                               inManagedObjectContext:context];
        object.apiPath = apiPath;
        object.name = @"";
        object.previewImagesObject = @"";
        [object.managedObjectContext saveToPersistentStore:nil];
        
        [streamCache setObject:object forKey:apiPath];
    }
    
    return object;
}

@end
