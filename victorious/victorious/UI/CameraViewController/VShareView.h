//
//  VShareView.h
//  victorious
//
//  Created by Will Long on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VShareView : UIView

@property (nonatomic, strong) UIColor* defaultColor;
@property (nonatomic, strong) UIColor* selectedColor;
/**
 *  Logic code that will fire before the selected state is changed.  Return a BOOL for the final selected state.
 *  Optional: if no selection block is provided, default logic swaps the selection state of the view.
 */
@property (nonatomic, strong) BOOL(^selectionBlock)();

- (BOOL)selected;
- (id)initWithTitle:(NSString*)title image:(UIImage*)image;

@end
