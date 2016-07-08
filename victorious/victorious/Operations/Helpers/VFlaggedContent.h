//
//  VFlaggedContent.h
//  victorious
//
//  Created by Sharif Ahmed on 9/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

/**
 Describes a kind of flag-able content
 */
typedef NS_ENUM(NSInteger, VFlaggedContentType)
{
    VFlaggedContentTypeStreamItem,
    VFlaggedContentTypeComment,
    VFlaggedContentTypeContent
};

extern const NSTimeInterval VDefaultRefreshTimeInterval;

/**
 Defines some helpful methods for managing the contents that a user has flagged
 */
@interface VFlaggedContent : NSObject

- (instancetype)initWithDefaults:(NSUserDefaults *)defaults;

- (instancetype)initWithDefaults:(NSUserDefaults *_Nullable)defaults
             refreshTimeInterval:(NSTimeInterval)timeInterval NS_DESIGNATED_INITIALIZER;

/**
 Determines the interval of time after which flagged content is considered old and and will
 be removed when `refreshFlaggedContents` is called.  A default value of 30 days is used
 if not set, as defined by `VDefaultRefreshTimeInterval`.
 */
@property (nonatomic, assign) NSTimeInterval refreshTimeInterval;

/**
 Removes contents that are sufficiently old from the flagged contents arrays
 */
- (void)refreshFlaggedContents;

/**
 Returns the ids of all flagged contents of the provided type.
 */
- (NSArray<NSString *> *)flaggedContentIdsWithType:(VFlaggedContentType)type;

/**
 Adds the provided id of a piece of content to the array flagged items of the provided type.
 
 @parameter remoteId The remote id of the content that should be tracked as flagged by the user.
 @parameter type The type of content being flagged.
 */
- (void)addRemoteId:(NSString *)remoteId toFlaggedItemsWithType:(VFlaggedContentType)type;

@end

NS_ASSUME_NONNULL_END
