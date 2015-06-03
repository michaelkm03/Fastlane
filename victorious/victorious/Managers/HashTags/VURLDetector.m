//
//  VURLDetector.m
//  victorious
//
//  Created by Patrick Lynch on 5/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VURLDetector.h"

@interface VURLDetector()

@property (nonatomic, strong) NSDataDetector *dataDetector;

@end

@implementation VURLDetector

- (NSDataDetector *)dataDetector
{
    if ( _dataDetector == nil )
    {
        _dataDetector = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    }
    return _dataDetector;
}

- (nonnull NSArray *)detectFromString:(nonnull NSString *)string
{
    NSMutableArray *output = [[NSMutableArray alloc] init];
    NSRange range = NSMakeRange( 0, string.length );
    NSArray *results = [self.dataDetector matchesInString:string options:0 range:range];
    
    for ( NSTextCheckingResult *result in results )
    {
        NSRange wordRange = [result rangeAtIndex:0];
        [output addObject:[NSValue valueWithRange:wordRange]];
    }
    
    return [output copy];
}

@end
