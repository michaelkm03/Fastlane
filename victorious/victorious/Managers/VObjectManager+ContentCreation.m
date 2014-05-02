//
//  VObjectManager+ContentCreation.m
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager+ContentCreation.h"

#import "VObjectManager+Private.h"

//Probably can remove these after we manually create the sequences
#import "VObjectManager+Sequence.h"
#import "VObjectManager+Comment.h"

#import "VSequence.h"
#import "VComment.h"

@implementation VObjectManager (ContentCreation)

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
        if ([fullResponse[@"error"] integerValue] == 0)
        {
            NSDictionary* payload = fullResponse[@"payload"];
            
            NSNumber* sequenceID = payload[@"sequence_id"];
            
            [self fetchSequence:sequenceID
                   successBlock:success
                      failBlock:fail];
        }
        else
        {
            NSError*    error = [NSError errorWithDomain:NSCocoaErrorDomain code:[fullResponse[@"error"] integerValue] userInfo:nil];
            if (fail)
                fail(operation, error);
        }
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
    
    NSString* loopParam = [self stringForLoopType:loopType];
    if (loopParam && speed)
    {
        parameters[@"speed"] = @(speed);
        parameters[@"playback"] = loopParam;
    }
    
    NSDictionary* allUrls = @{@"media_data":mediaUrl ?: [NSNull null]};
    
    VSuccessBlock fullSuccess = ^(NSOperation* operation, id fullResponse, NSArray* resultObjects)
    {
        NSDictionary* payload = fullResponse[@"payload"];
        
        NSNumber* sequenceID = payload[@"sequence_id"];
        
        [self fetchSequence:sequenceID
               successBlock:success
                  failBlock:fail];
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
    return nil;
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
        
        [self fetchCommentByID:[payload[@"id"] integerValue]
                  successBlock:success
                     failBlock:fail];
    };
    
    return [self uploadURLs:allURLs
                     toPath:@"/api/comment/add"
                 parameters:parameters
               successBlock:fullSuccess
                  failBlock:fail];
}

@end
