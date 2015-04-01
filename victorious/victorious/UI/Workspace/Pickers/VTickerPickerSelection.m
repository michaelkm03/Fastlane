//
//  TickerPickerSelection.m
//  victorious
//
//  Created by Patrick Lynch on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTickerPickerSelection.h"

NSString * const VTickerPickerSelectionModeKey = @"pickerSelectionMode";
NSString * const VTickerPickerSelectionSingle = @"multipleSelection";
NSString * const VTickerPickerSelectionMultiple = @"singleSelection";

@interface VTickerPickerSelection()

@property (nonatomic, strong) NSMutableSet *selectedIndexPaths;

@end

@implementation VTickerPickerSelection

+ (VTickerPickerSelectionMode)selectionModeFromString:(NSString *)string
{
    if ( [string isEqualToString:VTickerPickerSelectionSingle] )
    {
        return VTickerPickerSelectionModeSingle;
    }
    else if ( [string isEqualToString:VTickerPickerSelectionMultiple] )
    {
        return VTickerPickerSelectionModeMultiple;
    }
    
    return -1;
}

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
