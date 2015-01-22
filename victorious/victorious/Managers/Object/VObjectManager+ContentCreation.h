//
//  VObjectManager+ContentCreation.h
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"
#import "VUploadManager.h"

@class VSequence, VComment, VConversation, VAsset, VMessage, VNode, VPublishParameters;

typedef void (^VRemixCompletionBlock) (BOOL completion, NSURL *remixMp4Url, NSError *error);

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

@interface VObjectManager (ContentCreation)

- (RKManagedObjectRequestOperation *)fetchRemixMP4UrlForSequenceID:(NSNumber *)sequenceID
                                                      atStartTime:(CGFloat)startTime
                                                         duration:(CGFloat)duration
                                                  completionBlock:(VRemixCompletionBlock)completionBlock;

- (void)createPollWithName:(NSString *)name
               description:(NSString *)description
              previewImage:(UIImage *)previewImage
                  question:(NSString *)question
               answer1Text:(NSString *)answer1Text
               answer2Text:(NSString *)answer2Text
                 media1Url:(NSURL *)media1Url
                 media2Url:(NSURL *)media2Url
                completion:(VUploadManagerTaskCompleteBlock)completionBlock;

/**
 *  Upload a media with the given parameters object.
 *
 *  @param publishParameters The publish parameters.
 *  @param completionBlock   A completion block.
 */
- (void)uploadMediaWithPublishParameters:(VPublishParameters *)publishParameters
                              completion:(VUploadManagerTaskCompleteBlock)completionBlock;

/**
 Creates a new comment and posts it to the server
 
 @param text Text of the comment.  May be nil is media URL is not nil.
 @param mediaURL URL of media to be posted.  May be nil if text is not nil.
 @param sequence Sequence that comment was posted on
 @param asset Asset that comment was posted on
 @param parent Parent comment that is being replied to
 @param time Timestamp in seconds to post the realtime comment.  Use negative values for invalid times
 */
- (AFHTTPRequestOperation *)addCommentWithText:(NSString *)text
                                      mediaURL:(NSURL *)mediaURL
                                    toSequence:(VSequence *)sequence
                                     andParent:(VComment *)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;


/**
Creates a new realtime comment
 @param text Text of the comment.  May be nil is media URL is not nil.
 @param mediaURL URL of media to be posted.  May be nil is text is not nil.
 @param asset Asset that comment was posted on
 @param time Timestamp in seconds to post the realtime comment.  Use negative values for invalid times
 */
- (AFHTTPRequestOperation *)addRealtimeCommentWithText:(NSString *)text
                                              mediaURL:(NSURL *)mediaURL
                                                toAsset:(VAsset *)asset
                                                atTime:(NSNumber *)time
                                          successBlock:(VSuccessBlock)success
                                             failBlock:(VFailBlock)fail;

/**
 Creates a new message, but does not send it to the server.
 See sendMessage:successBlock:failBlock: for that.
 */
- (VMessage *)messageWithText:(NSString *)text
                 mediaURLPath:(NSString *)mediaURLPath;

/**
 Sends a new message to the server
 */
- (AFHTTPRequestOperation *)sendMessage:(VMessage *)message
                                 toUser:(VUser *)user
                           successBlock:(VSuccessBlock)success
                              failBlock:(VFailBlock)fail;

- (RKManagedObjectRequestOperation *)repostNode:(VNode *)node
                                       withName:(NSString *)name
                                   successBlock:(VSuccessBlock)success
                                      failBlock:(VFailBlock)fail;

@end
