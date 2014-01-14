//
//  VObjectManager.h
//  victoriOS
//
//  Created by Will Long on 11/29/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "RKObjectManager.h"
#import "VConstants.h"

/*! Block that executes when the API succeeds. 
 *  Block is given NSArray of objects RestKit created from response. */
typedef void (^SuccessBlock) (NSArray* resultObjects);

/*! Block that executes when the API fails.
 * Block is given NSError* that RestKit returned. */
typedef void (^FailBlock) (NSError* error);

typedef void (^PayloadSuccessBlock) (NSArray* resultObjects, NSDictionary* fullPayload);


/*! Block that will be given Pagination information from API Response.
 *  Block is given NSUInteger for page and NSUInteger for totalPages
 *  NOTE: VObjectManager does not keep track of Pagination Logic.*/
typedef void (^PaginationBlock) (NSUInteger page_number, NSUInteger page_total);


typedef float (^MyBlockType)(float, float);

@class VUser;
@class VSequence;
typedef NS_ENUM(NSUInteger, VObjectManagerSequenceCategoryType){
    VObjectManagerSequenceCategoryTypeAll,
    VObjectManagerSequenceCategoryTypeGeneral,
    VObjectManagerSequenceCategoryTypeFeatured
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

@property (nonatomic, strong) VUser*  mainUser;

@end

