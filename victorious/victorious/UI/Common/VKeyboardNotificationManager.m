//
//  VKeyboardNotificationManager.m
//  victorious
//
//  Created by Michael Sena on 1/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VKeyboardNotificationManager.h"

@interface VKeyboardNotificationManager ()

@property (nonatomic, copy) VKeyboardManagerKeyboardChangeBlock willShowBlock;
@property (nonatomic, copy) VKeyboardManagerKeyboardChangeBlock willHideBlock;
@property (nonatomic, copy) VKeyboardManagerKeyboardChangeBlock willChangeFrameBlock;

@end

@implementation VKeyboardNotificationManager

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillChangeFrameNotification
                                                  object:nil];
}

- (instancetype)initWithKeyboardWillShowBlock:(VKeyboardManagerKeyboardChangeBlock)willShowBlock
                                willHideBlock:(VKeyboardManagerKeyboardChangeBlock)willHideBlock
                         willChangeFrameBlock:(VKeyboardManagerKeyboardChangeBlock)willChangeFrameBlock
{
    self = [super init];
    if (self)
    {
        _willShowBlock = [willShowBlock copy];
        _willHideBlock = [willHideBlock copy];
        _willChangeFrameBlock = [willChangeFrameBlock copy];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillChange:)
                                                     name:UIKeyboardWillChangeFrameNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - Notification Handlers;

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self callHandlerWithNotification:notification
                              handler:self.willShowBlock];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self callHandlerWithNotification:notification
                              handler:self.willHideBlock];
}

- (void)keyboardWillChange:(NSNotification *)notification
{
    [self callHandlerWithNotification:notification
                              handler:self.willChangeFrameBlock];
}

- (void)callHandlerWithNotification:(NSNotification *)notification
                            handler:(VKeyboardManagerKeyboardChangeBlock)handler
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSValue *beingFrameValue = userInfo[UIKeyboardFrameBeginUserInfoKey];
    
    NSValue *endFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey];
    
    NSNumber *durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = durationValue.doubleValue;
    
    NSNumber *curveValue = userInfo[UIKeyboardAnimationCurveUserInfoKey];
    UIViewAnimationCurve animationCurve = curveValue.intValue;
    
    if (!self.stopCallingHandlerBlocks && handler != nil)
    {
        handler(beingFrameValue.CGRectValue,
                endFrameValue.CGRectValue,
                animationDuration,
                animationCurve);
    }
}

@end
