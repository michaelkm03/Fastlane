//
//  VCommentMedia.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <CoreData/CoreData.h>

@class VComment;

@interface VCommentMedia : NSManagedObject

@property (nonatomic, retain) NSString * mediaURL;
@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) VComment * comment;

@end
