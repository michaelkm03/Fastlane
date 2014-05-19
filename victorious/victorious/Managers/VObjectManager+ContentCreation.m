//
//  VObjectManager+ContentCreation.m
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+ContentCreation.h"

#import "VObjectManager+Private.h"
#import "VObjectManager+SequenceFilters.h"

#import "VHomeStreamViewController.h"
#import "VCommunityStreamViewController.h"
#import "VOwnerStreamViewController.h"

//Probably can remove these after we manually create the sequences
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"

#import "VSequence+Restkit.h"
#import "VNode+RestKit.h"
#import "VInteraction+RestKit.h"
#import "VAnswer+RestKit.h"
#import "VSequenceFilter.h"
#import "VCommentFilter.h"
#import "VComment.h"
#import "VUser+Fetcher.h"

@import AVFoundation;

@implementation VObjectManager (ContentCreation)

#pragma mark - Remix
- (RKManagedObjectRequestOperation*)fetchRemixMP4UrlForSequenceID:(NSNumber*)sequenceID
                                             atStartTime:(CGFloat)startTime
                                                duration:(CGFloat)duration
                                         completionBlock:(VRemixCompletionBlock)completionBlock
{
    VSuccessBlock success = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        VLog(@"Succeeded with objects: %@", resultObjects);
        if (completionBlock)
        {
            NSURL* remixURL = [NSURL URLWithString:fullResponse[@"payload"][@"mp4_url"]];
            completionBlock(YES, remixURL, nil);
        }
    };
    
    VFailBlock fail = ^(NSOperation* operation, NSError* error)
    {
        VLog(@"Failed with error: %@", error);
        if (completionBlock)
        {
            completionBlock(NO, nil, error);
        }
    };
    
    NSString* path = [[[@"/api/remix/fetch" stringByAppendingPathComponent:sequenceID.stringValue]
                       stringByAppendingPathComponent:@(startTime).stringValue]
                      stringByAppendingPathComponent:@(duration).stringValue];
    
    return [self GET:path object:nil parameters:nil successBlock:success failBlock:fail];
}

#pragma mark - Sequence Methods
- (AFHTTPRequestOperation * )createPollWithName:(NSString*)name
                                    description:(NSString*)description
                                       question:(NSString*)question
                                    answer1Text:(NSString*)answer1Text
                                    answer2Text:(NSString*)answer2Text
                                      media1Url:(NSURL*)media1Url
                                      media2Url:(NSURL*)media2Url
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    if(!media1Url || !media2Url)
        return nil;
    
    //Required Fields
    NSDictionary* parameters = @{@"name":name ?: [NSNull null],
                                 @"description":description ?: [NSNull null],
                                 @"question":question ?: [NSNull null],
                                 @"answer1_label" : answer1Text ?: [NSNull null],
                                 @"answer2_label" : answer2Text ?: [NSNull null]};
    
    NSDictionary *allURLs = @{@"answer1_media":media1Url,
                              @"answer2_media":media2Url};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        
        NSDictionary* payload = fullResponse[@"payload"];
        
        NSNumber* sequenceID = payload[@"sequence_id"];
        VSequence* newSequence = [self newPollWithID:sequenceID
                                                name:name
                                         description:description
                                         answer1Text:answer1Text
                                         answer2Text:answer2Text
                                   firstMediaURLPath:[media1Url absoluteString]
                                  secondMediaURLPath:[media2Url absoluteString]];
        
        [self fetchSequence:sequenceID successBlock:nil failBlock:nil];
        
        if (success)
            success(operation, fullResponse, @[newSequence]);
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/poll/create"
                 parameters:parameters
               successBlock:fullSuccess
                  failBlock:fail];
}

- (AFHTTPRequestOperation * )uploadMediaWithName:(NSString*)name
                                     description:(NSString*)description
                                       expiresAt:(NSString*)expiresAt
                                    parentNodeId:(NSNumber*)parentNodeId
                                           speed:(CGFloat)speed
                                        loopType:(VLoopType)loopType
                                    shareOptions:(VShareOptions)shareOptions
                                        mediaURL:(NSURL*)mediaUrl
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
                               shouldRemoveMedia:(BOOL)shouldRemoveMedia
{
    if (!mediaUrl)
        return nil;
    
    NSMutableDictionary* parameters = [@{@"name":name ?: [NSNull null],
                                         @"description":description ?: [NSNull null]} mutableCopy];
    if (expiresAt)
        parameters[@"expires_at"] = expiresAt;
    if (parentNodeId && ![parentNodeId isEqualToNumber:@(0)])
        parameters[@"parent_node_id"] = parentNodeId;
    if (shareOptions & kVShareToFacebook)
        parameters[@"share_facebook"] = @"1";
    if (shareOptions & kVShareToTwitter)
        parameters[@"share_twitter"] = @"1";
    
    if (parentNodeId && ![parentNodeId isEqualToNumber:@(0)])
    {
        NSString* loopParam = [self stringForLoopType:loopType];
        speed = speed ?: 1;
        
        parameters[@"speed"] = @(speed);
        parameters[@"playback"] = loopParam;
    }
    
    NSDictionary* allUrls = @{@"media_data":mediaUrl ?: [NSNull null]};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSDictionary* payload = fullResponse[@"payload"];
        
        NSNumber* sequenceID = payload[@"sequence_id"];
        VSequence* newSequence = [self newSequenceWithID:sequenceID
                                                    name:name
                                             description:description
                                            mediaURLPath:[mediaUrl absoluteString]];
        
        //Try to fetch the sequence
        [self fetchSequence:sequenceID successBlock:nil failBlock:nil];

        if (success)
            success(operation, fullResponse, @[newSequence]);
    };
    
    return [self uploadURLs:allUrls
                     toPath:@"/api/mediaupload/create"
                 parameters:[parameters copy]
               successBlock:fullSuccess
                  failBlock:fail];
}

- (NSString*)stringForLoopType:(VLoopType)type
{
    if (type == kVLoopRepeat)
        return @"loop";
    
    if (type == kVLoopReverse)
        return @"reverse";

    return @"once";
}

- (VSequence*)newSequenceWithID:(NSNumber*)remoteID
                           name:(NSString*)name
                    description:(NSString*)description
                   mediaURLPath:(NSString*)mediaURLPath
{
    VSequence* tempSequence = [self.mainUser.managedObjectContext insertNewObjectForEntityForName:[VSequence entityName]];
    
    tempSequence.remoteId = remoteID;
    tempSequence.name = name;
    tempSequence.sequenceDescription = description;
    tempSequence.releasedAt = [NSDate dateWithTimeIntervalSinceNow:-1];
    tempSequence.status = kTemporaryContentStatus;
    tempSequence.display_order = @(-1);
    tempSequence.category = [self.mainUser isOwner] ? kVOwnerImageCategory : kVUGCImageCategory;
    tempSequence.previewImage = [self localImageURLForVideo:mediaURLPath];

    [self.mainUser addPostedSequencesObject:tempSequence];
    
    //Add to home screen
    VSequenceFilter* homeFilter = [self sequenceFilterForCategories:[[VHomeStreamViewController sharedInstance] sequenceCategories]];
    [(VSequenceFilter*)[tempSequence.managedObjectContext objectWithID:homeFilter.objectID] addSequencesObject:tempSequence];
    
    //Add to community or owner (depends on user)
    NSArray* categoriesForSecondFilter = [self.mainUser isOwner] ? [[VOwnerStreamViewController sharedInstance] sequenceCategories]
                                                                 : [[VCommunityStreamViewController sharedInstance] sequenceCategories];
    VSequenceFilter* secondFilter = [self sequenceFilterForCategories:categoriesForSecondFilter];
    [(VSequenceFilter*)[tempSequence.managedObjectContext objectWithID:secondFilter.objectID] addSequencesObject:tempSequence];

    [tempSequence.managedObjectContext saveToPersistentStore:nil];
    
    return tempSequence;
}

- (VSequence*)newPollWithID:(NSNumber*)remoteID
                       name:(NSString*)name
                description:(NSString*)description
                answer1Text:(NSString*)answer1Text
                answer2Text:(NSString*)answer2Text
          firstMediaURLPath:(NSString*)firstmediaURLPath
         secondMediaURLPath:(NSString*)secondMediaURLPath
{
    VSequence* tempPoll = [self newSequenceWithID:remoteID name:name description:description mediaURLPath:nil];
    tempPoll.category = [self.mainUser isOwner] ? kVOwnerPollCategory : kVUGCPollCategory;
    
    VNode* node = [self.mainUser.managedObjectContext insertNewObjectForEntityForName:[VNode entityName]];
    VInteraction* interaction = [self.mainUser.managedObjectContext insertNewObjectForEntityForName:[VInteraction entityName]];

    VAnswer* firstAnswer = [self.mainUser.managedObjectContext insertNewObjectForEntityForName:[VAnswer entityName]];
    firstAnswer.label = answer1Text;
    firstAnswer.display_order = @(1);
    firstAnswer.thumbnailUrl = [self localImageURLForVideo:firstmediaURLPath];
    [interaction addAnswersObject:firstAnswer];
    
    VAnswer* secondAnswer = [self.mainUser.managedObjectContext insertNewObjectForEntityForName:[VAnswer entityName]];
    secondAnswer.label = answer2Text;
    secondAnswer.display_order = @(2);
    secondAnswer.thumbnailUrl = [self localImageURLForVideo:secondMediaURLPath];
    [interaction addAnswersObject:secondAnswer];
    
    [node addInteractionsObject:interaction];
    [tempPoll addNodesObject:node];
    
    [tempPoll.managedObjectContext saveToPersistentStore:nil];
    return tempPoll;
}

#pragma mark - Comment

- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                      mediaURL:(NSURL*)mediaURL
                                    toSequence:(VSequence*)sequence
                                     andParent:(VComment*)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    NSString* extension = [[mediaURL pathExtension] lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString* type = [extension isEqualToString:VConstantMediaExtensionMOV] || [extension isEqualToString:VConstantMediaExtensionMP4] ? @"video" : @"image";
    NSMutableDictionary* parameters = [@{@"sequence_id" : sequence.remoteId.stringValue ?: [NSNull null],
                                         @"parent_id" : parent.remoteId.stringValue ?: [NSNull null],
                                         @"text" : text ?: [NSNull null]} mutableCopy];
    NSDictionary *allURLs;
    if (mediaURL && type)
    {
        [parameters setObject:type forKey:@"media_type"];
        allURLs = @{@"media_data":mediaURL};
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        
        NSDictionary* payload = fullResponse[@"payload"];
        NSNumber* commentID = @([payload[@"id"] integerValue]);
        
        VComment* tempComment = [self newCommentWithID:commentID onSequence:sequence text:text mediaURLPath:[mediaURL absoluteString]];
        
        [self fetchCommentByID:[payload[@"id"] integerValue]
                  successBlock:nil
                     failBlock:nil];
        
        if (success)
            success(operation, fullResponse, @[tempComment]);
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/comment/add"
                 parameters:parameters
               successBlock:fullSuccess
                  failBlock:fail];
}

- (VComment*)newCommentWithID:(NSNumber*)remoteID
                   onSequence:(VSequence*)sequence
                         text:(NSString*)text
                 mediaURLPath:(NSString*)mediaURLPath
{
    VComment* tempComment = [sequence.managedObjectContext insertNewObjectForEntityForName:[VComment entityName]];
    
    tempComment.remoteId = remoteID;
    tempComment.text = text;
    tempComment.postedAt = [NSDate dateWithTimeIntervalSinceNow:-1];
    tempComment.sequenceId = sequence.remoteId;
    tempComment.mediaType = kTemporaryContentStatus;
    tempComment.display_order = @(-1);
    tempComment.thumbnailUrl = [self localImageURLForVideo:mediaURLPath];
    
    [sequence addCommentsObject:tempComment];
    sequence.commentCount = @(sequence.commentCount.integerValue + 1);
    
    [self.mainUser addCommentsObject:(VComment*)[self.mainUser.managedObjectContext objectWithID:tempComment.objectID]];
    
    VCommentFilter* filter = [[VObjectManager sharedManager] commentFilterForSequence:sequence];
    [(VCommentFilter*)[tempComment.managedObjectContext objectWithID:filter.objectID] addCommentsObject:tempComment];
    
    [tempComment.managedObjectContext saveToPersistentStore:nil];
    
    return tempComment;
}

#pragma mark - Helper methods

- (NSString*)localImageURLForVideo:(NSString*)localVideoPath
{
    NSString* extension = [[localVideoPath pathExtension] lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    if ([extension isEqualToString:VConstantMediaExtensionPNG] || [extension isEqualToString:VConstantMediaExtensionJPG]
        || [extension isEqualToString:VConstantMediaExtensionJPEG])
    {
        return localVideoPath;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:localVideoPath]];
    AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    CGImageRef imageRef = [assetGenerator copyCGImageAtTime:kCMTimeZero actualTime:NULL error:NULL];
    UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imgData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality);
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
    [imgData writeToURL:tempFile atomically:NO];
    
    return [tempFile absoluteString];
}
@end
