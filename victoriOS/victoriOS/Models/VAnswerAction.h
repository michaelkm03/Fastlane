//
//  VAnswerAction.h
//  victoriOS
//
//  Created by David Keegan on 12/12/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswer;

@interface VAnswerAction : NSManagedObject

@property (nonatomic, retain) NSNumber * gotoNode;
@property (nonatomic, retain) VAnswer *answer;

@end
