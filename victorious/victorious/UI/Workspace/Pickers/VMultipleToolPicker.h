//
//  VMultipleToolPicker.h
//  victorious
//
//  Created by Patrick Lynch on 4/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolPicker.h"

@protocol VMultipleToolPicker;

@protocol VMultipleToolPickerDelegate <VToolPickerDelegate>

- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index;
- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didDeselectItemAtIndex:(NSInteger)index;

@end

@protocol VMultipleToolPicker <NSObject>

@property (nonatomic, strong) id<VMultipleToolPickerDelegate> multiplePickerDelegate;

- (BOOL)toolIsSelectedAtIndex:(NSInteger)index;
- (void)selectToolAtIndex:(NSInteger)index;
- (void)deselectToolAtIndex:(NSInteger)index;

@end