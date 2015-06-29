//
//  VLikersDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikersDataSource.h"
#import "VObjectManager+Pagination.h"
#import "VSequence.h"

@interface VLikersDataSource ()

@property (nonatomic, strong) VSequence *sequence;

@end

@implementation VLikersDataSource

- (instancetype)initWithSequence:(VSequence *)sequence
{
    NSParameterAssert( sequence != nil );
    
    self = [super init];
    if ( self != nil )
    {
        _sequence = sequence;
    }
    return self;
}

#pragma mark - VUsersDataSource

- (NSString *)noContentTitle
{
    return NSLocalizedString( @"NoLikersTitle", @"" );
}

- (NSString *)noContentMessage
{
    return NSLocalizedString( @"NoLikersMessage", @"" );
}

- (UIImage *)noContentImage
{
    return [UIImage imageNamed:@"noLikersIcon"];
}

- (void)refreshWithPageType:(VPageType)pageType completion:(void(^)(BOOL success, NSError *error))completion
{
    [[VObjectManager sharedManager] likersForSequence:self.sequence pageType:pageType
                                         successBlock:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         completion( YES, nil );
         
     } failBlock:^(NSOperation *operation, NSError *error)
     {
         completion( NO, error );
     }];
}

- (NSArray *)users
{
    return self.sequence.likers.allObjects;
}

@end
