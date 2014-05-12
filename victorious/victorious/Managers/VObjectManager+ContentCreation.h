//
//  VObjectManager+ContentCreation.h
//  victorious
//
//  Created by Will Long on 5/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VObjectManager.h"
#import "VConstants.h"

@class VSequence, VComment;

typedef void (^VRemixCompletionBlock) (BOOL completion, NSURL* remixMp4Url, NSError* error);

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
                                       expiresAt:(NSString*)expiresAt
                                    parentNodeId:(NSNumber*)parentNodeId
                                           speed:(CGFloat)speed
                                        loopType:(VLoopType)loopType
                                    shareOptions:(VShareOptions)shareOptions
                                        mediaURL:(NSURL*)mediaUrl
                                    successBlock:(VSuccessBlock)success
                                       failBlock:(VFailBlock)fail
                               shouldRemoveMedia:(BOOL)shouldRemoveMedia;


- (AFHTTPRequestOperation *)addCommentWithText:(NSString*)text
                                      mediaURL:(NSURL*)mediaURL
                                    toSequence:(VSequence*)sequence
                                     andParent:(VComment*)parent
                                  successBlock:(VSuccessBlock)success
                                     failBlock:(VFailBlock)fail;
@end
