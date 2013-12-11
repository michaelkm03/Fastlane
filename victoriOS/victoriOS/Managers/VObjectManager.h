//
//  VObjectManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "RKObjectManager.h"

@class VUser;
@class VSequence;
typedef NS_ENUM(NSUInteger, VObjectManagerSequenceCategoryType){
    VObjectManagerSequenceCategoryTypeAll,
    VObjectManagerSequenceCategoryTypePublic,
    VObjectManagerSequenceCategoryTypePrivate
};

typedef NS_ENUM(NSUInteger, VObjectManagerSequenceStatusType){
    VObjectManagerSequenceStatusTypeNone,
    VObjectManagerSequenceStatusTypePublic,
    VObjectManagerSequenceStatusTypePrivate
};

@interface VObjectManager : RKObjectManager

+ (void)setupObjectManager;

@end

@interface VObjectManager (Login)

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email password:(NSString *)password
                                                          block:(void(^)(VUser *user, NSError *error))block;
- (RKManagedObjectRequestOperation *)createVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password
                                                                 name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;
- (RKManagedObjectRequestOperation *)updateVictoriousAccountWithEmail:(NSString *)email password:(NSString *)password
                                                                 name:(NSString *)name block:(void(^)(VUser *user, NSError *error))block;

@end

@interface VObjectManager (Sequence)

- (RKManagedObjectRequestOperation *)loadSequenceWithId:(NSNumber *)sequenceId withBlock:(void(^)(VSequence *sequence, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequenceCategories:(VObjectManagerSequenceCategoryType)type
                                                  withBlock:(void(^)(NSArray *categories, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequencesForStatus:(VObjectManagerSequenceStatusType)type page:(NSUInteger)page perPage:(NSUInteger)perPage
                                                 withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block;
- (RKManagedObjectRequestOperation *)loadSequencesForCategory:(VObjectManagerSequenceCategoryType)categoryType
                                                      status:(VObjectManagerSequenceStatusType)statusType
                                                        page:(NSUInteger)page perPage:(NSUInteger)perPage
                                                   withBlock:(void(^)(NSUInteger page, NSUInteger perPage, NSArray *sequences, NSError *error))block;

@end
