//
//  VStreamItem+Fetcher.m
//  victorious
//
//  Created by Will Long on 9/19/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamItem+Fetcher.h"
#import "VEditorializationItem+Restkit.h"
#import "victorious-Swift.h"

//Type values
NSString * const VStreamItemTypeSequence = @"sequence";
NSString * const VStreamItemTypeStream = @"stream";
NSString * const VStreamItemTypeMarquee = @"marquee";
NSString * const VStreamItemTypeUser = @"user";
NSString * const VStreamItemTypeHashtag = @"hashtag";
NSString * const VStreamItemTypeFeed = @"feed";

//Subtype values
NSString * const VStreamItemSubTypeImage = @"image";
NSString * const VStreamItemSubTypeVideo = @"video";
NSString * const VStreamItemSubTypePoll = @"poll";
NSString * const VStreamItemSubTypeText = @"text";
NSString * const VStreamItemSubTypeContent = @"content";
NSString * const VStreamItemSubTypeStream = @"stream";

@implementation VStreamItem (Fetcher)

- (BOOL)isContent
{
    if ( self.itemType != nil )
    {
        return [self.itemType isEqualToString:VStreamItemTypeSequence];
    }
    return self.streamContentType == nil;
}

- (BOOL)isSingleStream
{
    if ( self.itemSubType != nil )
    {
        return [self.itemSubType isEqualToString:VStreamItemSubTypeContent];
    }
    return [self.streamContentType isEqualToString:VStreamItemSubTypeContent];
}

- (BOOL)isStreamOfStreams
{
    if ( self.itemType != nil )
    {
        return [self.itemSubType isEqualToString:VStreamItemSubTypeStream];
    }
    return [self.streamContentType isEqualToString:VStreamItemSubTypeStream];
}

- (NSArray *)previewImagePaths
{
    if ([self.previewImagesObject isKindOfClass:[NSArray class]] || !self.previewImagesObject)
    {
        return self.previewImagesObject;
    }
    else if ([self.previewImagesObject isKindOfClass:[NSString class]])
    {
        return @[self.previewImagesObject];
    }
    else
    {
        NSAssert(false, @"undefined type for sequence.previewImage");
        return nil;
    }
}

- (NSURL *)previewImageUrl
{
    NSString *previewImageString = nil;
    if ( [self.previewImagesObject isKindOfClass:[NSString class]] )
    {
        previewImageString = self.previewImagesObject;
    }
    else if ( [self.previewImagesObject isKindOfClass:[NSArray class]] )
    {
        for ( id object in self.previewImagesObject )
        {
            if ( [object isKindOfClass:[NSString class]] )
            {
                previewImageString = object;
                break;
            }
        }
    }
    
    return [NSURL URLWithString:previewImageString];
}

- (VEditorializationItem *)editorializationForStreamWithApiPath:(NSString *)apiPath
{
    NSManagedObjectContext *context = self.managedObjectContext;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[VEditorializationItem entityName]];
    NSPredicate *idFilter = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@", @"apiPath", apiPath, @"streamItemId", self.remoteId];
    [request setPredicate:idFilter];
    NSError *error = nil;
    VEditorializationItem *editorializationItem = [[context executeFetchRequest:request error:&error] firstObject];
    if (error != nil)
    {
        VLog(@"Error occured in editorializationForStreamWithApiPath: %@", error);
    }
    
    if ( editorializationItem == nil )
    {
        //Create a new one if it doesn't exist
        editorializationItem = [NSEntityDescription insertNewObjectForEntityForName:[VEditorializationItem entityName]
                                               inManagedObjectContext:context];
        editorializationItem.apiPath = apiPath;
        editorializationItem.streamItemId = self.remoteId;
        [editorializationItem.managedObjectContext saveToPersistentStore:nil];
    }
    
    return editorializationItem;
}

@end
