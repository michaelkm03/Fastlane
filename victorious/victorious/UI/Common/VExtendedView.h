//
//  VExtendedView.h
//  victorious
//
//  Created by Michael Sena on 10/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface VExtendedView : UIView

@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat cornerRadius;

@end
