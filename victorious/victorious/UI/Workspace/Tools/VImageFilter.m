//
//  VImageFilter.m
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VImageFilter.h"

@implementation VImageFilter

- (UIViewController *)canvasToolViewController
{
    return nil;
}

- (UIViewController *)inspectorToolViewController
{
    return nil;
}

- (NSString *)title
{
    return self.filter.name;
}

@end
