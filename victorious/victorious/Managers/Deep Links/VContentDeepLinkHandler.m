//
//  VContentDeepLinkHandler.m
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <MBProgressHUD.h>

#import "VObjectManager+Sequence.h"
#import "VDependencyManager+VObjectManager.h"
#import "VContentDeepLinkHandler.h"
#import "VScaffoldViewController.h"
#import "NSURL+VPathHelper.h"
#import "VDependencyManager+VScaffoldViewController.h"

static NSString * const kContentDeeplinkURLHostComponent = @"content";
static NSString * const kCommentDeeplinkURLHostComponent = @"comment";

@interface VContentDeepLinkHandler()

@property (nonatomic, weak) VScaffoldViewController *scaffoldViewController;
@property (nonatomic, weak) VDependencyManager *dependencyManager;

@end

@implementation VContentDeepLinkHandler

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        NSParameterAssert( _dependencyManager != nil );
        NSParameterAssert( [_dependencyManager objectManager] != nil );
                              
        _scaffoldViewController = [dependencyManager scaffoldViewController];
        NSParameterAssert( _scaffoldViewController != nil );
    }
    return self;
}

- (instancetype)init
{
    NSAssert(NO, @"Use the designated initializer");
    return nil;
}

- (BOOL)requiresAuthorization
{
    return NO;
}

- (BOOL)canDisplayContentForDeeplinkURL:(NSURL *)url
{
    const BOOL isHostValid = [url.host isEqualToString:kContentDeeplinkURLHostComponent] || [url.host isEqualToString:kCommentDeeplinkURLHostComponent];
    const BOOL isSequenceValid = [url v_firstNonSlashPathComponent] != nil;
    return isHostValid && isSequenceValid;
}

- (void)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        completion( NO, nil );
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scaffoldViewController.view animated:YES];
    
    NSString *sequenceID = [url v_firstNonSlashPathComponent];
    
    NSNumber *commentId = nil;
    NSString *commentIDString = [url v_pathComponentAtIndex:2];
    if ( commentIDString != nil )
    {
        commentId = @([commentIDString integerValue]);
    }
    
    NSString *streamId = [url v_pathComponentAtIndex:3];
    
    [[self.dependencyManager objectManager] fetchSequenceByID:sequenceID
                                         inStreamWithStreamID:streamId
                                                 successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [hud hide:YES];
         VSequence *sequence = (VSequence *)[resultObjects firstObject];
         [self.scaffoldViewController showContentViewWithSequence:sequence streamID:streamId commentId:commentId placeHolderImage:nil];
         completion( YES, nil );
     }
                                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         [hud hide:YES];
         completion( NO, nil );
     }];
}

@end
