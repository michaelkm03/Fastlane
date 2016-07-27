//
//  VMultipleToolPicker.h
//  victorious
//
//  Created by Patrick Lynch on 4/1/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VToolPicker.h"

@protocol VMultipleToolPicker;

/**
 A deleted designed for a VMultipleToolPicker that responds to selections of
 options that are presented in the picker.
 */
@protocol VMultipleToolPickerDelegate <VToolPickerDelegate>

/**
 Indicates that item was selected, either programmatically or by user input.  Multiple
 selection is enabled, meaning that this may not be the only item selected and
 other item are not automatically deselected when a selection is made.
 */
- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index;

/**
 Indicates that item was deselected, either programmatically or by user input.  Multiple
 selection is enabled, meaning that one, none or multiple other items may currently be selected.
 */
- (void)toolPicker:(id<VMultipleToolPicker>)toolPicker didDeselectItemAtIndex:(NSInteger)index;

@end

/**
 A tool picker that allows selection of more than one option at a time, such as a checkbox list
 (as opposed to a radio list, which only allows one selection).
 */
@protocol VMultipleToolPicker <NSObject>

/**
 A delegate that when supplied can respond to selection and deselection messages.
 */
@property (nonatomic, strong) id<VMultipleToolPickerDelegate> multiplePickerDelegate;

/**
 Returns whether or not the item at the supplied index is currently selected.
 */
- (BOOL)toolIsSelectedAtIndex:(NSInteger)index;

/**
 Selects the tool at the specified index, if it exists.
 */
- (void)selectToolAtIndex:(NSInteger)index;

/**
 Deselects the tool at the specified index, if it exists.
 */
- (void)deselectToolAtIndex:(NSInteger)index;

@end
