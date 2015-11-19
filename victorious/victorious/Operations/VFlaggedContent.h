//
//  VFlaggedContent.h
//  victorious
//
//  Created by Sharif Ahmed on 9/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

/**
 Describes a kind of flag-able content
 */
typedef NS_ENUM(NSInteger, VFlaggedContentType)
{
    VFlaggedContentTypeStreamItem,
    VFlaggedContentTypeComment
};

/**
 Defines some helpful methods for managing the contents that a user has flagged
 */
@interface VFlaggedContent : NSObject

/**
 Removes contents that are sufficiently old from the flagged contents arrays
 */
- (void)refreshFlaggedContents;

/**
 Creates an array of comments after removing those flagged by a user on this device.
 
 @parameter comments The array of comments that could contain flagged comments.
 
 @return An array of comments minus those that have been flagged by a user on this device.
 */
- (NSArray *)commentsAfterStrippingFlaggedItems:(NSArray *)comments;

/**
 Creates an array of stream items after removing those flagged by a user on this device.
 
 @parameter streamItems The array of stream items that could contain flagged stream items.
 
 @return An array of stream items minus those that have been flagged by a user on this device.
 */
- (NSArray *)streamItemsAfterStrippingFlaggedItems:(NSArray *)streamItems;

/**
 Returns the ids of all flagged contents of the provided type.
 
 @parameter type The type of content whose content ids are desired.
 
 @return An array of strings representing the remote ids of contents that have been flagged.
 */
- (NSArray *)flaggedContentIdsWithType:(VFlaggedContentType)type;

/**
 Adds the provided id of a piece of content to the array flagged items of the provided type.
 
 @parameter remoteId The remote id of the content that should be tracked as flagged by the user.
 @parameter type The type of content being flagged.
 */
- (void)addRemoteId:(NSString *)remoteId toFlaggedItemsWithType:(VFlaggedContentType)type;

@end
