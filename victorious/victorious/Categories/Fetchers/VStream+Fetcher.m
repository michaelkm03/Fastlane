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
#import "VUser.h"
#import "VPaginationManager.h"
#import "NSCharacterSet+VURLParts.h"

@implementation VStream (Fetcher)

- (BOOL)isHashtagStream
{
    return self.hashtag != nil;
}

- (BOOL)hasMarquee
{
    return self.marqueeItems.count > 0;
}

+ (VStream *)streamForUser:(VUser *)user
{
    NSString *streamID = user.remoteId.stringValue ?: @"0";
    NSString *escapedRemoteId = [streamID stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet v_pathPartCharacterSet]];
    NSString *apiPath = [NSString stringWithFormat:@"/api/sequence/detail_list_by_user/%@/%@/%@",
                         escapedRemoteId, VPaginationManagerPageNumberMacro, VPaginationManagerItemsPerPageMacro];
    return [self streamForPath:apiPath withID:streamID inContext:[[VObjectManager sharedManager].managedObjectStore mainQueueManagedObjectContext]];
}

+ (VStream *)streamForPath:(NSString *)apiPath
                    withID:(NSString *)streamID
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
        if ( streamID != nil )
        {
            object.remoteId = streamID;
        }
        [object.managedObjectContext saveToPersistentStore:nil];
        
        [streamCache setObject:object forKey:apiPath];
    }
    
    return object;
}

@end
