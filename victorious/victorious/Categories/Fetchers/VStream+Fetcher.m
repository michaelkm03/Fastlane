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
#import "VThemeManager.h"
#import "VUser.h"

static NSString * const kVSequenceContentType = @"sequence";
static NSString * const kVStreamContentTypeContent = @"content";
static NSString * const kVStreamContentTypeStream = @"stream";

NSString * const VStreamFollowerStreamPath = @"/api/sequence/follows_detail_list_by_stream/";

NSString * const VStreamFilterTypeRecent = @"recent";
NSString * const VStreamFilterTypePopular = @"popular";

@implementation VStream (Fetcher)

- (BOOL)onlyContainsSequences
{
    return [self.streamContentType isEqualToString:kVStreamContentTypeContent];
}

- (BOOL)isStreamOfStreams
{
    return [self.streamContentType isEqualToString:kVStreamContentTypeStream];
}

+ (VStream *)remixStreamForSequence:(VSequence *)sequence
{
    NSString *apiPath = [@"/api/sequence/remixes_by_sequence/" stringByAppendingString: sequence.remoteId ?: @"0"];
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
    VStream *stream = [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.name = NSLocalizedString(@"Recent", nil);
    return stream;
}

+ (VStream *)hotSteamForSteamName:(NSString *)streamName
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/hot_detail_list_by_stream/" stringByAppendingString: streamName];
    VStream *stream = [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
    stream.name = NSLocalizedString(@"Featured", nil);
    return stream;
}

+ (VStream *)streamForHashTag:(NSString *)hashTag
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");
    NSString *apiPath = [@"/api/sequence/detail_list_by_hashtag/" stringByAppendingString: hashTag];
    return [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)followerStreamForStreamName:(NSString *)streamName user:(VUser *)user
{
    NSAssert([NSThread isMainThread], @"Filters should be created on the main thread");

    user = user ?: [VObjectManager sharedManager].mainUser;
    
    NSString *apiPath = [@"/api/sequence/follows_detail_list_by_stream/" stringByAppendingString: user.remoteId.stringValue ?: @"0"];
    apiPath = [apiPath stringByAppendingPathComponent:streamName];
    VStream *stream = [self streamForPath:apiPath managedObjectContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
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
    return [self streamForRemoteId:@"marquee" filterName:nil managedObjectContext:context];
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
    
    VStream *stream = [self streamForPath:apiPath managedObjectContext:context];
    stream.remoteId = remoteId;
    stream.filterName = filterName;
    [stream.managedObjectContext saveToPersistentStore:nil];
    return stream;
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
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([VStream class])];
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
        object = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([VStream class])
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
