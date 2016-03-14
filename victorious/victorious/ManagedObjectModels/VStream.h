//
//  VStream.h
//  victorious
//
//  Created by Sharif Ahmed on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

NS_ASSUME_NONNULL_BEGIN

@class VStreamItem;

@interface VStream : VStreamItem

@property (nonatomic, retain, nullable) NSString * apiPath;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain, nullable) NSString * filterName;
@property (nonatomic, retain, nullable) NSString * hashtag;
@property (nonatomic, retain, nullable) NSNumber * isUserPostAllowed;
@property (nonatomic, retain, nullable) NSString * trackingIdentifier;
@property (nonatomic, retain, nullable) NSString * shelfId;
@property (nonatomic, retain) NSOrderedSet *streamItemPointers; //< VStreamItemPointer

@end

NS_ASSUME_NONNULL_END
