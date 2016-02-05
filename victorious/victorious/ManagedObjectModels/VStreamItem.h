//
//  VStreamItem.h
//  victorious
//
//  Created by Sharif Ahmed on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStream, VImageAsset, VAsset, VStreamItemPointer;

NS_ASSUME_NONNULL_BEGIN

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain, nullable) NSString * name;
@property (nonatomic, retain, nullable) id previewImagesObject;
@property (nonatomic, retain, nullable) VAsset * previewTextPostAsset;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain, nullable) NSString * streamContentType;
@property (nonatomic, retain, nullable) NSString * itemType;
@property (nonatomic, retain, nullable) NSString * itemSubType;
@property (nonatomic, retain, nullable) NSSet * marquees;
@property (nonatomic, retain, nullable) NSSet * previewImageAssets;
@property (nonatomic, retain, nullable) NSDate * releasedAt;

@end

NS_ASSUME_NONNULL_END
