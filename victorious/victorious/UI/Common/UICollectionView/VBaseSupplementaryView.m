//
//  VBaseSupplementaryView.m
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseSupplementaryView.h"

@implementation VBaseSupplementaryView

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:NSStringFromClass([self class])
                          bundle:nil];
}

+ (NSString *)nibName
{
    
    NSLog(@"cell id %@", [self cellIdentifier]);
    return [self cellIdentifier];
}

+ (NSString *)cellIdentifier
{
    static NSString* _cellIdentifier = nil;
    _cellIdentifier = NSStringFromClass([self class]);
    return _cellIdentifier;
}

@end
