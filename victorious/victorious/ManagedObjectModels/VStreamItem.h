//
//  VStreamItem.h
//  victorious
//
//  Created by Sharif Ahmed on 8/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VEditorializationItem, VStream, VImageAsset, VAsset, VStreamChild;

NS_ASSUME_NONNULL_BEGIN

@interface VStreamItem : NSManagedObject

@property (nonatomic, retain, nullable) NSString * headline;
@property (nonatomic, retain, nullable) NSString * name;
@property (nonatomic, retain, nullable) id previewImagesObject;
@property (nonatomic, retain, nullable) VAsset * previewTextPostAsset;
@property (nonatomic, retain) NSString * remoteId;
@property (nonatomic, retain, nullable) NSString * streamContentType;
@property (nonatomic, retain, nullable) NSString * streamId;
@property (nonatomic, retain, nullable) NSString * itemType;
@property (nonatomic, retain, nullable) NSString * itemSubType;
@property (nonatomic, retain, nullable) NSSet * editorializations;
@property (nonatomic, retain, nullable) NSSet * marquees;
@property (nonatomic, retain, nullable) NSSet * previewImageAssets;
@property (nonatomic, retain, nullable) NSDate * releasedAt;
@property (nonatomic, retain) NSSet * streamChildrenInSream; //< VStreamChild

@end

NS_ASSUME_NONNULL_END
