//
//  VObjectManager+ContentCreation.m
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSURL+MediaType.h"
#import "VObjectManager+ContentCreation.h"

#import "VObjectManager+Private.h"
#import "VObjectManager+Pagination.h"
#import "VUploadManager.h"
#import "VUploadTaskCreator.h"

//Probably can remove these after we manually create the sequences
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"

#import "VSequence+Restkit.h"
#import "VNode+RestKit.h"
#import "VInteraction+RestKit.h"
#import "VAnswer+RestKit.h"
#import "VAsset.h"
#import "VMessage+RestKit.h"
#import "VUser+Fetcher.h"

@import AVFoundation;

NSString * const VObjectManagerContentWillBeCreatedNotification = @"VObjectManagerContentWillBeCreatedNotification";
NSString * const VObjectManagerContentWasCreatedNotification    = @"VObjectManagerContentWasCreatedNotification";
NSString * const VObjectManagerContentFilterIDKey               = @"filterID";
NSString * const VObjectManagerContentIndexKey                  = @"index";

@implementation VObjectManager (ContentCreation)

#pragma mark - Remix

- (RKManagedObjectRequestOperation *)fetchRemixMP4UrlForSequenceID:(NSNumber *)sequenceID
                                             atStartTime:(CGFloat)startTime
                                                duration:(CGFloat)duration
                                         completionBlock:(VRemixCompletionBlock)completionBlock
{
    VSuccessBlock success = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if (completionBlock)
        {
            NSURL *remixURL = [NSURL URLWithString:fullResponse[kVPayloadKey][@"mp4_url"]];
            completionBlock(YES, remixURL, nil);
        }
    };
    
    VFailBlock fail = ^(NSOperation *operation, NSError *error)
    {
        VLog(@"Failed with error: %@", error);
        if (completionBlock)
        {
            completionBlock(NO, nil, error);
        }
    };
    
    NSString *path = [[[@"/api/remix/fetch" stringByAppendingPathComponent:sequenceID.stringValue]
                       stringByAppendingPathComponent:@(startTime).stringValue]
                      stringByAppendingPathComponent:@(duration).stringValue];
    
    return [self GET:path object:nil parameters:nil successBlock:success failBlock:fail];
}

#pragma mark - Sequence Methods

- (void)createPollWithName:(NSString *)name
               description:(NSString *)description
              previewImage:(UIImage *)previewImage
                  question:(NSString *)question
               answer1Text:(NSString *)answer1Text
               answer2Text:(NSString *)answer2Text
                 media1Url:(NSURL *)media1Url
                 media2Url:(NSURL *)media2Url
                completion:(VUploadManagerTaskCompleteBlock)completionBlock
{
    NSParameterAssert(media1Url != nil && media2Url != nil);
    if (!media1Url || !media2Url)
    {
        if (completionBlock)
        {
            completionBlock(nil, nil, nil, [NSError errorWithDomain:kVictoriousErrorDomain code:0 userInfo:nil]);
        }
        return;
    }
    
    NSDictionary *parameters = @{@"name": name ?: [NSNull null],
                                 @"description": description ?: [NSNull null],
                                 @"question": question ?: [NSNull null],
                                 @"answer1_label" : answer1Text ?: [NSNull null],
                                 @"answer2_label" : answer2Text ?: [NSNull null],
                                 @"answer1_media": media1Url,
                                 @"answer2_media": media2Url,
                                };
    
    NSURL *endpoint = [NSURL URLWithString:@"/api/poll/create" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:endpoint];
    request.HTTPMethod = RKStringFromRequestMethod(RKRequestMethodPOST);
    
    VUploadTaskCreator *uploadTaskCreator = [[VUploadTaskCreator alloc] initWithUploadManager:self.uploadManager];
    uploadTaskCreator.request = request;
    uploadTaskCreator.formFields = parameters;
    uploadTaskCreator.previewImage = previewImage;
    
    NSError *uploadCreationError = nil;
    VUploadTaskInformation *uploadTask = [uploadTaskCreator createUploadTaskWithError:&uploadCreationError];
    if (!uploadTask)
    {
        if (completionBlock)
        {
            if (!uploadCreationError)
            {
                uploadCreationError = [NSError errorWithDomain:kVictoriousErrorDomain code:0 userInfo:nil];
            }
            completionBlock(nil, nil, nil, uploadCreationError);
        }
        return;
    }
    [self.uploadManager enqueueUploadTask:uploadTask onComplete:completionBlock];
}

- (void)uploadMediaWithName:(NSString *)name
                description:(NSString *)description
               previewImage:(UIImage *)previewImage
                captionType:(VCaptionType)type
                  expiresAt:(NSString *)expiresAt
               parentNodeId:(NSNumber *)parentNodeId
                      speed:(CGFloat)speed
                   loopType:(VLoopType)loopType
                   mediaURL:(NSURL *)mediaUrl
                 completion:(VUploadManagerTaskCompleteBlock)completionBlock
{
    NSParameterAssert(mediaUrl != nil);
    if (!mediaUrl)
    {
        if (completionBlock)
        {
            completionBlock(nil, nil, nil, [NSError errorWithDomain:kVictoriousErrorDomain code:0 userInfo:nil]);
        }
        return;
    }
    
    NSMutableDictionary *parameters = [@{@"name": name ?: [NSNull null],
                                         @"description": description ?: [NSNull null],
                                         @"media_data": mediaUrl,
                                       } mutableCopy];
    if (expiresAt)
    {
        parameters[@"expires_at"] = expiresAt;
    }
    if (parentNodeId && ![parentNodeId isEqualToNumber:@(0)])
    {
        parameters[@"parent_node_id"] = [parentNodeId stringValue];
    }

    if (type == VCaptionTypeMeme)
    {
        parameters[@"subcategory"] = @"meme";
    }
    else if (type == VCaptionTypeQuote)
    {
        parameters[@"subcategory"] = @"secret";
    }
    
    if (parentNodeId && ![parentNodeId isEqualToNumber:@(0)])
    {
        NSString *loopParam = [self stringForLoopType:loopType];
        speed = speed ?: 1;
        
        parameters[@"speed"] = @(speed);
        parameters[@"playback"] = loopParam;
    }
    
    NSURL *endpoint = [NSURL URLWithString:@"/api/mediaupload/create" relativeToURL:self.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:endpoint];
    request.HTTPMethod = RKStringFromRequestMethod(RKRequestMethodPOST);
    
    VUploadTaskCreator *uploadTaskCreator = [[VUploadTaskCreator alloc] initWithUploadManager:self.uploadManager];
    uploadTaskCreator.request = request;
    uploadTaskCreator.formFields = parameters;
    uploadTaskCreator.previewImage = previewImage;

    NSError *uploadCreationError = nil;
    VUploadTaskInformation *uploadTask = [uploadTaskCreator createUploadTaskWithError:&uploadCreationError];
    if (!uploadTask)
    {
        if (completionBlock)
        {
            if (!uploadCreationError)
            {
                uploadCreationError = [NSError errorWithDomain:kVictoriousErrorDomain code:0 userInfo:nil];
            }
            completionBlock(nil, nil, nil, uploadCreationError);
        }
        return;
    }
    [self.uploadManager enqueueUploadTask:uploadTask onComplete:completionBlock];
}

- (RKManagedObjectRequestOperation *)repostNode:(VNode *)node
                                       withName:(NSString *)name
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    parameters[@"parent_node_id"] = node.remoteId ?: [NSNull null];
    if (name)
    {
        parameters[@"name"] = name;
    }
    
    return [self POST:@"/api/repost/create"
               object:nil
           parameters:parameters
         successBlock:success
            failBlock:fail];
}

- (NSString *)stringForLoopType:(VLoopType)type
{
    if (type == VLoopRepeat)
    {
        return @"loop";
    }
    
    if (type == VLoopReverse)
    {
        return @"reverse";
    }

    return @"once";
}

#pragma mark - Comment

- (AFHTTPRequestOperation *)addRealtimeCommentWithText:(NSString *)text
                                              mediaURL:(NSURL *)mediaURL
                                                toAsset:(VAsset *)asset
                                                atTime:(NSNumber *)time
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail
{
    return [self addCommentWithText:text
                           mediaURL:mediaURL
                         toSequence:asset.node.sequence
                              asset:asset
                          andParent:nil
                             atTime:time
                       successBlock:success
                          failBlock:fail];
}

- (AFHTTPRequestOperation *)addCommentWithText:(NSString *)text
                                      mediaURL:(NSURL *)mediaURL
                                    toSequence:(VSequence *)sequence
                                     andParent:(VComment *)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    return [self addCommentWithText:text
                           mediaURL:mediaURL
                         toSequence:sequence
                              asset:nil
                          andParent:parent
                             atTime:@(-1)
                       successBlock:success
                          failBlock:fail];
}

- (AFHTTPRequestOperation *)addCommentWithText:(NSString *)text
                                      mediaURL:(NSURL *)mediaURL
                                    toSequence:(VSequence *)sequence
                                         asset:(VAsset *)asset
                                     andParent:(VComment *)parent
                                        atTime:(NSNumber *)time
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail
{
    NSString *extension = [[mediaURL pathExtension] lowercaseStringWithLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    NSString *type = [extension isEqualToString:VConstantMediaExtensionMOV] || [extension isEqualToString:VConstantMediaExtensionMP4] ? @"video" : @"image";
    NSMutableDictionary *parameters = [@{@"sequence_id" : sequence.remoteId ?: [NSNull null],
                                         @"parent_id" : parent.remoteId.stringValue ?: [NSNull null],
                                         @"text" : text ?: [NSNull null]} mutableCopy];
    NSDictionary *allURLs;
    if (mediaURL && type)
    {
        [parameters setObject:type forKey:@"media_type"];
        allURLs = @{@"media_data":mediaURL};
    }
    if (time.doubleValue >= 0 && asset.remoteId)
    {
        [parameters setObject:asset.remoteId forKey:@"asset_id"];
        [parameters setObject:time forKey:@"realtime"];
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        VComment *newComment;
        
        if ([[resultObjects firstObject] isKindOfClass:[VComment class]])
        {
            newComment = [resultObjects firstObject];
        }
        else
        {
            NSDictionary *payload = fullResponse[kVPayloadKey];
            NSNumber *commentID = @([payload[@"id"] integerValue]);
            newComment = [self newCommentWithID:commentID onSequence:sequence text:text mediaURLPath:[mediaURL absoluteString]];
            newComment.realtime = time;
            [self fetchCommentByID:[payload[@"id"] integerValue] successBlock:nil failBlock:nil];
        }
        
        if (asset)
        {
            [asset addCommentsObject: newComment];
        }
        
        if (success)
        {
            success(operation, fullResponse, @[newComment]);
        }
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/comment/add"
                 parameters:parameters
               successBlock:fullSuccess
                  failBlock:fail];
}

- (VComment *)newCommentWithID:(NSNumber *)remoteID
                   onSequence:(VSequence *)sequence
                         text:(NSString *)text
                 mediaURLPath:(NSString *)mediaURLPath
{
    VComment *tempComment = [sequence.managedObjectContext insertNewObjectForEntityForName:[VComment entityName]];
    
    tempComment.remoteId = remoteID;
    tempComment.text = text;
    tempComment.postedAt = [NSDate dateWithTimeIntervalSinceNow:-1];
    tempComment.sequenceId = sequence.remoteId;
    tempComment.mediaType = kTemporaryContentStatus;
    tempComment.thumbnailUrl = [self localImageURLForVideo:mediaURLPath];
    tempComment.mediaUrl = mediaURLPath;
    tempComment.userId = self.mainUser.remoteId;
    
    [sequence addCommentsObject:tempComment];
    sequence.commentCount = @(sequence.commentCount.integerValue + 1);
    
    VUser *userInContext = (VUser *)[tempComment.managedObjectContext objectWithID:self.mainUser.objectID];
    [userInContext addCommentsObject:tempComment];
    
    NSMutableOrderedSet *comments = [[NSMutableOrderedSet alloc] initWithObject:[sequence.managedObjectContext objectWithID:tempComment.objectID]];
    [comments addObjectsFromArray:sequence.comments.array];
    sequence.comments = comments;
    [tempComment.managedObjectContext saveToPersistentStore:nil];
    
    return tempComment;
}

#pragma mark - Messages

- (AFHTTPRequestOperation *)sendMessage:(VMessage *)message
                                 toUser:(VUser *)user
                           successBlock:(VSuccessBlock)success
                              failBlock:(VFailBlock)fail
{
    //Set the parameters
    NSDictionary *parameters = [@{@"to_user_id" : user.remoteId.stringValue ?: [NSNull null],
                                  @"text" : message.text ?: [NSNull null]
                                  } mutableCopy];
    NSDictionary *allURLs;
    if (message.mediaPath)
    {
        NSURL *mediaURL = [NSURL URLWithString:message.mediaPath];
        allURLs = @{@"media_data": mediaURL};
        NSString *type = [message.mediaPath v_hasVideoExtension] ? @"video" : @"image";
        [parameters setValue:type forKey:@"media_type"];
    }
    
    VSuccessBlock fullSuccess = ^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
    {
        if ([fullResponse isKindOfClass:[NSDictionary class]])
        {
            [message.managedObjectContext performBlock:^(void)
            {
                NSNumber *returnedId = @([fullResponse[kVPayloadKey][@"message_id"] integerValue]);
                if (![message.remoteId isEqualToNumber:returnedId])
                {
                    message.remoteId = returnedId;
                    [message.managedObjectContext saveToPersistentStore:nil];
                }
            }];
        }
        if (success)
        {
            success(operation, fullResponse, resultObjects);
        }
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/message/send"
                 parameters:[parameters copy]
               successBlock:fullSuccess
                  failBlock:fail];
}

- (VMessage *)messageWithText:(NSString *)text
                 mediaURLPath:(NSString *)mediaURLPath
{
    NSAssert([NSThread isMainThread], @"This method should be called only on the main thread");
    VMessage *tempMessage = [self.managedObjectStore.mainQueueManagedObjectContext insertNewObjectForEntityForName:[VMessage entityName]];
    
    tempMessage.text = text;
    tempMessage.postedAt = [NSDate dateWithTimeIntervalSinceNow:-1];
    tempMessage.thumbnailPath = [self localImageURLForVideo:mediaURLPath];
    tempMessage.mediaPath = mediaURLPath;
    tempMessage.sender = self.mainUser;
    tempMessage.senderUserId = self.mainUser.remoteId;
    
    return tempMessage;
}

#pragma mark - Helper methods

- (NSString *)localImageURLForVideo:(NSString *)localVideoPath
{
    if (!localVideoPath)
    {
        return nil;
    }
    
    if ([localVideoPath v_hasImageExtension])
    {
        return localVideoPath;
    }
    
    AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:localVideoPath]];
    AVAssetImageGenerator *assetGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    NSError *error;
    CMTime time = CMTimeMake(asset.duration.value / 2, asset.duration.timescale);
    CGImageRef imageRef = [assetGenerator copyCGImageAtTime:time actualTime:NULL error:&error];
    if (error)
    {
        return nil;
    }
    
    UIImage *previewImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    NSData *imgData = UIImageJPEGRepresentation(previewImage, VConstantJPEGCompressionQuality);
    
    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
    [imgData writeToURL:tempFile atomically:NO];
    
    return [tempFile absoluteString];
}

@end
