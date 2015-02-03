//
//  VTextField.h
//  victorious
//
//  Created by Michael Sena on 2/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStringValidator;

@interface VTextField : UITextField

@property (nonatomic, strong) VStringValidator *validator;

@end
