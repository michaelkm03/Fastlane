//
//  VPickerTextField.h
//  HIFramework-iOS
//
//  Created by Gary Philipp on 1/28/14.
//  Copyright (c) 2014 Gary Philipp. All rights reserved.
//

@class VPickerTextField;

@protocol VPickerTextFieldDelegate <NSObject>
@required
- (void)pickerTextField:(VPickerTextField *)pickerTextField didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
@optional
- (void)pickerTextFieldDidClear:(VPickerTextField *)pickerTextField;
@end

@interface VPickerTextField : UITextField
@property (nonatomic, weak) id<VPickerTextFieldDelegate> pickerDelegate;
@property (nonatomic, strong) NSArray *pickerData;

@end
