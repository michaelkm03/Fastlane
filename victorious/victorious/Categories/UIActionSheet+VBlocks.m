//
//  UIActionSheet+VBlocks.m
//  victorious
//
//  Created by Josh Hinman on 4/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIActionSheet+VBlocks.h"

#import <objc/runtime.h>

@interface VActionSheetBlockDelegate : NSObject <UIActionSheetDelegate>

@property (nonatomic, copy)     void                (^onDestructiveButton)(void);
@property (nonatomic, copy)     void                (^onCancel)(void);
@property (nonatomic, readonly) NSMutableDictionary  *otherBlocks;

@end

@implementation VActionSheetBlockDelegate

- (id)init
{
    self = [super init];
    if (self)
    {
        _otherBlocks = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        if (self.onDestructiveButton)
        {
            self.onDestructiveButton();
        }
    }
    else
    {
        void (^block)(void) = _otherBlocks[@(buttonIndex)];
        if (block)
        {
            block();
        }
    }
}

- (void)actionSheetCancel:(UIActionSheet *)actionSheet
{
    if (self.onCancel)
    {
        self.onCancel();
    }
    else if (actionSheet.cancelButtonIndex != -1)
    {
        [self actionSheet:actionSheet clickedButtonAtIndex:actionSheet.cancelButtonIndex];
    }
}

@end

#pragma mark -

static char kActionSheetDelegateKey;

@implementation UIActionSheet (VBlocks)

- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
               onCancelButton:(void (^)(void))cancelButtonBlock
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
          onDestructiveButton:(void (^)(void))destructiveButtonBlock
   otherButtonTitlesAndBlocks:(NSString *)firstButtonTitle, ...
{
    self = [self initWithTitle:title delegate:nil cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
    if (self)
    {
        VActionSheetBlockDelegate *delegate = [[VActionSheetBlockDelegate alloc] init];
        delegate.onDestructiveButton = destructiveButtonBlock;
        
        va_list buttonTitles;
        va_start(buttonTitles, firstButtonTitle);
        for (id buttonTitle = firstButtonTitle; buttonTitle != nil; buttonTitle = va_arg(buttonTitles, NSString *))
        {
            void (^handler)(void) = va_arg(buttonTitles, void (^)(void));
            NSInteger index = [self addButtonWithTitle:buttonTitle];
            delegate.otherBlocks[@(index)] = [handler copy];
        }
        va_end(buttonTitles);
        
        if (cancelButtonTitle)
        {
            NSInteger cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle];
            self.cancelButtonIndex = cancelButtonIndex;
            if (cancelButtonBlock)
            {
                delegate.otherBlocks[@(cancelButtonIndex)] = [cancelButtonBlock copy];
            }
        }
        
        self.delegate = delegate;
        objc_setAssociatedObject(self, &kActionSheetDelegateKey, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return self;
}

- (NSInteger)addButtonWithTitle:(NSString *)title block:(void (^)(void))block
{
    VActionSheetBlockDelegate *delegate = objc_getAssociatedObject(self, &kActionSheetDelegateKey);
    if (delegate)
    {
        NSInteger index = [self addButtonWithTitle:title];
        if (block)
        {
            delegate.otherBlocks[@(index)] = [block copy];
        }
        return index;
    }
    else
    {
        return 0;
    }
}

- (void)setOnActionSheetCancel:(void (^)(void))cancelBlock
{
    VActionSheetBlockDelegate *delegate = objc_getAssociatedObject(self, &kActionSheetDelegateKey);
    delegate.onCancel = cancelBlock;
}

@end
