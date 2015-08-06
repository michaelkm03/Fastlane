//
//  VShelf.h
//  victorious
//
//  Created by Sharif Ahmed on 8/5/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "VStreamItem.h"

@class VStream;

@interface VShelf : VStreamItem

@property (nonatomic, retain) VStream *stream;

@end
