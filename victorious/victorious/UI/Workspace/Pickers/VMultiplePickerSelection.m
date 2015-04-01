//
//  VMultiplePickerSelection.m
//  victorious
//
//  Created by Patrick Lynch on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMultiplePickerSelection.h"

@interface VMultiplePickerSelection()

@property (nonatomic, strong) NSMutableSet *selectedIndexPaths;

@end

@implementation VMultiplePickerSelection

- (void)resetSelectedIndexPaths
{
    self.selectedIndexPaths = nil;
}

- (void)indexPathWasSelected:(NSIndexPath *)indexPath
{
    [self.selectedIndexPaths addObject:indexPath];
}

- (void)indexPathWasDeselected:(NSIndexPath *)indexPath
{
    [self.selectedIndexPaths removeObject:indexPath];
}

- (BOOL)isIndexPathSelected:(NSIndexPath *)indexPath
{
    return [self.selectedIndexPaths containsObject:indexPath];
}

- (NSMutableSet *)selectedIndexPaths
{
    if ( _selectedIndexPaths == nil )
    {
        _selectedIndexPaths = [[NSMutableSet alloc] init];
    }
    return _selectedIndexPaths;
}

@end
