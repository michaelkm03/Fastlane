//
//  VAlternateCaptureOption.m
//  victorious
//
//  Created by Michael Sena on 7/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAlternateCaptureOption.h"

@implementation VAlternateCaptureOption

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
            andSelectionBlock:(VImageVideoLibraryAlternateCaptureSelection)selectionBlock
{
    NSParameterAssert(title != nil);
    NSParameterAssert(icon != nil);
    NSParameterAssert(selectionBlock != nil);
    
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _icon = icon;
        _selectionBlock = [selectionBlock copy];
    }
    return self;
}

@end
