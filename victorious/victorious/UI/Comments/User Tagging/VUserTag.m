//
//  VUserTag.m
//  victorious
//
//  Created by Sharif Ahmed on 2/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VUserTag.h"

@interface VUserTag ()

@property (nonatomic, readwrite) NSNumber *remoteId;

@end

@implementation VUserTag

- (instancetype)initWithDisplayString:(NSString *)displayString
              databaseFormattedString:(NSString *)databaseFormattedString
                             remoteId:(NSNumber *)remoteId
               andTagStringAttributes:(NSDictionary *)tagStringAttributes
{
    self = [super initWithDisplayString:displayString
                          databaseFormattedString:databaseFormattedString
                           andTagStringAttributes:tagStringAttributes];
    if ( self != nil )
    {
        self.remoteId = remoteId;
    }
    return self;
}

@end
