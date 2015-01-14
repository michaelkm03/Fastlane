//
//  VAbstractFilter.h
//  victorious
//
//  Created by Will Long on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VAbstractFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * currentPageNumber;
@property (nonatomic, retain) NSString * filterAPIPath;
@property (nonatomic, retain) NSNumber * maxPageNumber;
@property (nonatomic, retain) NSNumber * perPageNumber;
@property (nonatomic, retain) NSNumber * totalItemsNumber;

@end
