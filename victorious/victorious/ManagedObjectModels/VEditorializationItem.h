//
//  VEditorializationItem.h
//  victorious
//
//  Created by Sharif Ahmed on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStreamItem;

@interface VEditorializationItem : NSManagedObject

@property (nonatomic, retain) NSString * headline;
@property (nonatomic, retain) NSString * apiPath;
@property (nonatomic, retain) NSString * streamItemId;
@property (nonatomic, retain) NSString * marqueeHeadline;
@property (nonatomic, retain) VStreamItem *streamItem;

@end
