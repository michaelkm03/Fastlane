//
//  VAsset.h
//  victorious
//
//  Created by Sharif Ahmed on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VNode;

@interface VAsset : NSManagedObject

@property (nonatomic, retain) NSNumber * audioMuted;
@property (nonatomic, retain) NSString * backgroundColor;
@property (nonatomic, retain) NSString * backgroundImageUrl;
@property (nonatomic, retain) NSString * data;
@property (nonatomic, retain) NSNumber * loop;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSNumber * nodeId;
@property (nonatomic, retain) NSNumber * playerControlsDisabled;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSNumber * speed;
@property (nonatomic, retain) NSNumber * streamAutoplay;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) VNode *node;
@property (nonatomic, retain) NSNumber *remotePlayback;
@property (nonatomic, retain) NSString *remoteSource;
@property (nonatomic, retain) NSString *remoteContentId;

@end
