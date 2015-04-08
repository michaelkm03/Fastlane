//
//  VCrossFadingLabel.h
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VCrossFadingLabel : UILabel

/**
    Sets up the label with the given strings and textAttributes such that each string
        is shown at full opacity when the offset is at the string's location in the strings
        array and the label is fully transparent when the offset is exactly halfway between
        two array index values.
 
    @param strings An array of NSStrings that will be swapped between based on the offset property of this class
    @param textAttributes A dictionary of stringAttributes that will be used to style the label text
 */
- (void)setupWithStrings:(NSArray *)strings andTextAttributes:(NSDictionary *)textAttributes;

/**
    An array of NSStrings that will be displayed in the label
 */
@property (nonatomic, readonly) NSArray *strings;

/**
    The string attributes used to style the text inside this label.
    Adjusting this property will reload the label
 */
@property (nonatomic, strong) NSDictionary *textAttributes;

/**
    Determines which string is displayed in the label and the opacity of the label.
        This class interpolates alpha values between those provided in this example:
        At an offset of 0, the first string in the strings array is shown at full opacity;
        at an offset of 0.5, the label is fully transparent; at an offset of 1, the string
        at index 1 of the strings array is shown at full opacity
 */
@property (nonatomic, assign) CGFloat offset;

/**
    When set to yes, the value of offset is bounded to [0, strings.count - 1] which causes
        this label to display at full-opacity even when an outside class attempts to set "offset"
        to a value outside this normalized range. Defaults to NO, allowing for offset values
        outside the [0, strings.count - 1] range to cause a partially transparent label to be shown
 */
@property (nonatomic, assign) BOOL opaqueOutsideArrayRange;

@end
