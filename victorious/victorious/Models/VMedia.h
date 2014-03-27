//
//  VMedia.h
//  victorious
//
//  Created by Will Long on 1/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VMessage;

@interface VMedia : NSManagedObject

@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * mediaUrl;
@property (nonatomic, retain) NSString * previewImage;
@property (nonatomic, retain) VMessage *message;

@end
