//
//  VEditableTextPostHashtagHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VEditableTextPostHashtagHelper : NSObject

@property (nonatomic, strong, readonly) NSArray *removed;

@property (nonatomic, strong, readonly) NSArray *added;

@property (nonatomic, strong, readonly) NSMutableSet *embeddedHashtags;

- (BOOL)addHashtag:(NSString *)hashtag;

- (BOOL)removeHashtag:(NSString *)hashtag;

- (void)setHashtagModificationsWithBeforeText:(NSString *)beforeText afterText:(NSString *)afterText;

- (void)resetCachedModifications;

@end
