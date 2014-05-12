//
//  VAbstractPaginator.h
//  victorious
//
//  Created by Will Long on 4/28/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VAbstractPaginator : NSManagedObject

@property (nonatomic, retain) NSString * apiPath;
@property (nonatomic, retain) NSNumber * maxPageNumber;
@property (nonatomic, retain) NSNumber * currentPageNumber;
@property (nonatomic, retain) NSNumber * updating;
@property (nonatomic, retain) NSNumber * perPageNumber;

@end
