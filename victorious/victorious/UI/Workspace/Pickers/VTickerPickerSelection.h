//
//  TickerPickerSelection.h
//  victorious
//
//  Created by Patrick Lynch on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const VTickerPickerSelectionModeKey;
extern NSString * const VTickerPickerSelectionSingle;
extern NSString * const VTickerPickerSelectionMultiple;

typedef NS_ENUM( NSInteger, VTickerPickerSelectionMode )
{
    VTickerPickerSelectionModeSingle,
    VTickerPickerSelectionModeMultiple
};

@interface VTickerPickerSelection : NSObject

+ (VTickerPickerSelectionMode)selectionModeFromString:(NSString *)string;

- (void)resetSelectedIndexPaths;

- (void)indexPathWasSelected:(NSIndexPath *)indexPath;

- (void)indexPathWasDeselected:(NSIndexPath *)indexPath;

- (BOOL)isIndexPathSelected:(NSIndexPath *)indexPath;

@end
