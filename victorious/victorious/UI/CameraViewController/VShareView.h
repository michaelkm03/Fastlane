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

- (BOOL)selected;
- (id)initWithTitle:(NSString*)title image:(UIImage*)image;

@end
