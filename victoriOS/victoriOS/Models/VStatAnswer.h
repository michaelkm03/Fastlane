//
//  VStatAnswer.h
//  victoriOS
//
//  Created by David Keegan on 12/9/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VStatInteraction;

@interface VStatAnswer : NSManagedObject

@property (nonatomic, retain) NSNumber * answer_id;
@property (nonatomic, retain) NSNumber * currency;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * is_correct;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) VStatInteraction *interaction;

@end
