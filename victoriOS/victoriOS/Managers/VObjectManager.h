//
//  VObjectManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "RKObjectManager.h"

/*! Block that executes when the API succeeds. 
 *  Block is given NSArray of objects RestKit created from response. */
typedef void (^SuccessBlock) (NSArray*);

/*! Block that executes when the API fails.
 * Block is given NSError* that RestKit returned. */
typedef void (^FailBlock) (NSError*);
/*! Block that will be given Pagination information from API Response.
 *  Block is given NSUInteger for page and NSUInteger for totalPages
 *  NOTE: VObjectManager does not keep track of Pagination Logic.*/
typedef void (^PaginationBlock) (NSUInteger, NSUInteger);


typedef float (^MyBlockType)(float, float);

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

/*! Sets up [VObjectManager sharedManager] and declares RK entities and descriptors
 */
+ (void)setupObjectManager;

@end

@interface VObjectManager (Login)



- (RKManagedObjectRequestOperation *)loginToFacebookWithSuccessBlock:(SuccessBlock)success
                                                           failBlock:(FailBlock)failed;

- (RKManagedObjectRequestOperation *)loginToVictoriousWithEmail:(NSString *)email
                                                       password:(NSString *)password
                                                   successBlock:(SuccessBlock)success
                                                      failBlock:(FailBlock)fail;

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
