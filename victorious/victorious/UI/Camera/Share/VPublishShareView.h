//
//  VPublishShareView.h
//  victorious
//
//  Created by Will Long on 8/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, VShareViewSelectedState)
{
    VShareViewSelectedStateNotSelected = 0,
    VShareViewSelectedStateLimbo, ///< Button is asynchronously transitioning from the not selected to the selected state
    VShareViewSelectedStateSelected,
};

@interface VPublishShareView : UIView

@property (nonatomic, strong) UIColor*  defaultColor;
@property (nonatomic, strong) UIColor*  selectedColor;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, strong) UIImage*  image;
@property (nonatomic, strong) void (^selectionBlock)(); ///< Called when the view is tapped

@property (nonatomic) VShareViewSelectedState selectedState;

- (id)initWithTitle:(NSString *)title image:(UIImage *)image;

@end
