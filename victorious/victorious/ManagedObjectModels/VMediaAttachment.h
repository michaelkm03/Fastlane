//
//  VCommentMedia.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CoreData/CoreData.h>

@class VComment, VMessage;

@interface VMediaAttachment : NSManagedObject

@property (nonatomic, retain) NSString * mediaURL;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) VComment * comment;
@property (nonatomic, retain) VMessage * message;

@end
