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

@end
