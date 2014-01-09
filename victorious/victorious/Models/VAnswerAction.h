//
//  VAnswerAction.h
//  victorious
//
//  Created by Will Long on 1/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VAnswer;

@interface VAnswerAction : NSManagedObject

@property (nonatomic, retain) NSNumber * gotoNode;
@property (nonatomic, retain) VAnswer *answer;

@end
