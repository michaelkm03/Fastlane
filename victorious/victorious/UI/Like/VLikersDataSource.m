//
//  VLikersDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLikersDataSource.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"

@interface VLikersDataSource ()

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSArray *likers;

@end

@implementation VLikersDataSource

- (instancetype)initWithUser:(VSequence *)sequence
{
    NSParameterAssert( sequence != nil );
    
    self = [super init];
    if (self)
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
    [[VObjectManager sharedManager] likersForSequence:self.sequence
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
