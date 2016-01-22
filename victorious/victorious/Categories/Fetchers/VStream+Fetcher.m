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
#import "VUser.h"

@import VictoriousIOSSDK;

@implementation VStream (Fetcher)

- (BOOL)isHashtagStream
{
    return self.hashtag != nil;
}

- (BOOL)hasMarquee
{
    return self.marqueeItems.count > 0;
}

- (BOOL)hasShelfID
{
    return self.shelfId != nil && ![self.shelfId isEqualToString:@""];
}

+ (VStream *)streamForPath:(NSString *)apiPath
                 inContext:(NSManagedObjectContext *)context
            withEntityName:(NSString *)entityName
{
    static NSCache *streamCache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
                  ^{
                      streamCache = [[NSCache alloc] init];
                  });
    
    VStream *object = [streamCache objectForKey:apiPath];
    if ( object != nil )
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
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
    NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"%K == %@", @"apiPath", apiPath];
    [request setPredicate:idFilter];
    NSError *error = nil;
    object = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in commentForId: %@", error);
    }
    
    if ( object != nil )
    {
        [streamCache setObject:object forKey:apiPath];
    }
    else
    {
        //Create a new one if it doesn't exist
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName
                                               inManagedObjectContext:context];
        object.apiPath = apiPath;
        object.name = @"";
        object.previewImagesObject = @"";
        [object.managedObjectContext saveToPersistentStore:nil];
        
        [streamCache setObject:object forKey:apiPath];
    }
    
    return object;
}

+ (VStream *)streamForPath:(NSString *)apiPath
                 inContext:(NSManagedObjectContext *)context
{
    return [self streamForPath:apiPath inContext:context withEntityName:[VStream entityName]];
}

@end
