//
//  VButton.h
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM( NSUInteger, VButtonStyle ) {
    VButtonStylePrimary,
    VButtonStyleSecondary
};

@interface VButton : UIButton

@property (nonatomic, assign) IBInspectable VButtonStyle style;

@end
