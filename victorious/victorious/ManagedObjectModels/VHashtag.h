//
//  VHashtag.h
//  victorious
//
//  Created by Patrick Lynch on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VHashtag : NSManagedObject

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain) NSNumber *count;

@end
