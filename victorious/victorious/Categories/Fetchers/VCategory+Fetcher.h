//
//  VCategory+Fetcher.h
//  victorious
//
//  Created by Will Long on 1/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCategory.h"

@interface VCategory (Fetcher)

+ (VCategory*)fetchCategoryWithName:(NSString*)name;

@end
