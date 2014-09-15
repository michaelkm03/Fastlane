//
//  VContentViewViewModel.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentViewViewModel.h"

// Model Categories
#import "VSequence+Fetcher.h"

@interface VContentViewViewModel ()

@property (nonatomic, strong, readwrite) VSequence *sequence;

@end

@implementation VContentViewViewModel

#pragma mark - Initializers

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        _sequence = sequence;
        
        if ([sequence isPoll])
        {
            _type = VContentViewTypePoll;
        }
        else if ([sequence isVideo])
        {
            _type = VContentViewTypeVideo;
        }
        else if ([sequence isImage])
        {
            _type = VContentViewTypeImage;
        }
        else
        {
            // Unsupported type
        }
    }
    return self;
}

- (id)init
{
    [[NSException exceptionWithName:@"Invalid initializer."
                            reason:@"-init is not allowed. Use the designate initializer: \"-initWithSequence:\""
                           userInfo:nil] raise];
    return nil;
}

@end
