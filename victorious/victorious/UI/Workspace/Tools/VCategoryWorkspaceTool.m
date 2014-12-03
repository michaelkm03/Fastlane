//
//  VCategoryWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCategoryWorkspaceTool.h"

@interface VCategoryWorkspaceTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) NSArray *subTools;

@end

@implementation VCategoryWorkspaceTool

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
                     subTools:(NSArray *)subTools
{
    self = [super init];
    if (self)
    {
        _title = title;
        _icon = icon;
        _subTools = subTools;
    }
    
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, title: %@, icon: %@, subtools: %@]", [super description], self.title, self.icon, self.subTools];
}

#pragma mark - VWorkspaceTool

- (NSString *)title
{
    return _title;
}

- (UIImage *)icon
{
    return _icon;
}

- (NSArray *)subTools
{
    return _subTools;
}

@end
