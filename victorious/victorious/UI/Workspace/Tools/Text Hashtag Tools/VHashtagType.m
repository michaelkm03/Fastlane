//
//  VHashtagType.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagType.h"

@interface VHashtagType ()

@property (nonatomic, assign) BOOL isDefault;
@property (nonatomic, strong) NSString *hashtagText;

@end

@implementation VHashtagType

- (instancetype)initWithHashtagText:(NSString *)hashtagText isDefault:(BOOL)isDefault
{
    self = [super init];
    if (self) {
        _isDefault = isDefault;
        _hashtagText = hashtagText;
    }
    return self;
}

- (NSString *)title
{
    return self.hashtagText;
}

@end
