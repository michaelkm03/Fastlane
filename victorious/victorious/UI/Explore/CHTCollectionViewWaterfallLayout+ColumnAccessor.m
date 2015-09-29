//
//  CHTCollectionViewWaterfallLayout+ColumnAccessor.m
//  victorious
//
//  Created by Sharif Ahmed on 8/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "CHTCollectionViewWaterfallLayout+ColumnAccessor.h"

@implementation CHTCollectionViewWaterfallLayout (ColumnAccessor)

@dynamic columnHeights;

- (NSArray *)heightsForColumnsInSection:(NSUInteger)section
{
    return self.columnHeights[section];
}

@end
