//
//  VObjectManager+ContentCreation.h
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"

@class VSequence, VComment, VConversation, VAsset, VNode;

typedef void (^VRemixCompletionBlock) (BOOL completion, NSURL* remixMp4Url, NSError* error);

/**
 Notification posted when new content is created by the user and will be added to a filter
 */
extern NSString * const VObjectManagerContentWillBeCreatedNotification;

/**
 Notification posted when new content is created by the user and has been added to a filter
 */
extern NSString * const VObjectManagerContentWasCreatedNotification;

/**
 Notification.userInfo dictionary key specifying the filter to which
 new content was/will be added. The value is a core data objectID.
 */
extern NSString * const VObjectManagerContentFilterIDKey;

/**
 Notification.userInfo dictionary key specifying the index where new content was/will be added
 */
extern NSString * const VObjectManagerContentIndexKey;

typedef NS_ENUM(NSUInteger, VCaptionType)
{
    vNormalCaption = 0,
    vMemeCaption,
    VQuoteCaption
};

@interface VObjectManager (ContentCreation)

- (RKManagedObjectRequestOperation*)fetchRemixMP4UrlForSequenceID:(NSNumber*)sequenceID
                                                      atStartTime:(CGFloat)startTime
                                                         duration:(CGFloat)duration
                                                  completionBlock:(VRemixCompletionBlock)completionBlock;

- (AFHTTPRequestOperation * )createPollWithName:(NSString*)name
                                    description:(NSString*)description
                                       question:(NSString*)question
                                    answer1Text:(NSString*)answer1Text
                                    answer2Text:(NSString*)answer2Text
                                      media1Url:(NSURL*)media1Url
                                      media2Url:(NSURL*)media2Url
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation * )uploadMediaWithName:(NSString*)name
                                     description:(NSString*)description
                                     captionType:(VCaptionType)type
                                       expiresAt:(NSString*)expiresAt
                                    parentNodeId:(NSNumber*)parentNodeId
                                           speed:(CGFloat)speed
                                        loopType:(VLoopType)loopType
                                    shareOptions:(VShareOptions)shareOptions
                                        mediaURL:(NSURL*)mediaUrl
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;


- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                      mediaURL:(NSURL*)mediaURL
                                    toSequence:(VSequence*)sequence
                                     andParent:(VComment*)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;


/**
Creates a new realtime comment
 @param text Text of the comment.  May be nil is media URL is not nil.
 @param mediaURL URL of media to be posted.  May be nil is text is not nil.
 @param asset Asset that comment was posted on
 @param time Timestamp in seconds to post the realtime comment.  Use negative values for invalid times
 */
- (AFHTTPRequestOperation *)addRealtimeCommentWithText:(NSString*)text
                                              mediaURL:(NSURL*)mediaURL
                                                toAsset:(VAsset*)asset
                                                atTime:(NSNumber*)time
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

- (AFHTTPRequestOperation *)sendMessageToConversation:(VConversation*)conversation
                                             withText:(NSString*)text
                                             mediaURL:(NSURL*)mediaURL
                                         successBlock:(VSuccessBlock)success
                                            failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation * )repostNode:(VNode*)node
                                        withName:(NSString*)name
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail;

- (VSequence*)newSequenceWithID:(NSNumber*)remoteID
                           name:(NSString*)name
                    description:(NSString*)description
                   mediaURLPath:(NSString*)mediaURLPath;

@end
