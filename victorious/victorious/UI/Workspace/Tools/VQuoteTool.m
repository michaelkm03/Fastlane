//
//  VQuoteWorkspaceTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VQuoteTool.h"

#import "VDependencyManager.h"

static NSString * const kTitleKey = @"title";

@interface VQuoteTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

@end

@implementation VQuoteTool

@synthesize renderIndex = _renderIndex;

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
    }
    
    return self;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    return inputImage;
}

@end
