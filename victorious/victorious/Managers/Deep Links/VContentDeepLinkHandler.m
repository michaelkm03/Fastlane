//
//  VContentDeepLinkHandler.m
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VContentDeepLinkHandler.h"
#import "NSURL+VPathHelper.h"
#import "VDependencyManager+VTabScaffoldViewController.h"
#import "VTabScaffoldViewController.h"
#import "victorious-Swift.h"

#define DEEP_LINK_TO_COMMENT_ENABLED 0

@import MBProgressHUD;

static NSString * const kContentDeeplinkURLHostComponent = @"content";
static NSString * const kCommentDeeplinkURLHostComponent = @"comment";

@interface VContentDeepLinkHandler()

@property (nonatomic, weak) VTabScaffoldViewController *scaffoldViewController;
@property (nonatomic, weak) VDependencyManager *dependencyManager;
@property (nonatomic, strong) ContentViewPresenter *contentViewPresenter;

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
        
        _contentViewPresenter = [[ContentViewPresenter alloc] init];
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
    
    NSString *sequenceID = [url v_firstNonSlashPathComponent];
    NSNumber *commentId = nil;
    
#if DEEP_LINK_TO_COMMENT_ENABLED
    NSString *commentIDString = [url v_pathComponentAtIndex:2];
    if ( commentIDString != nil )
    {
        commentId = @([commentIDString integerValue]);
    }
#endif
    
    NSString *streamId = [url v_pathComponentAtIndex:3];
    
    ContentViewContext *context = [[ContentViewContext alloc] init];
    context.streamId = streamId;
    context.commentId = commentId;
    context.viewController = self.scaffoldViewController.rootNavigationController;
    context.originDependencyManager = self.dependencyManager;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scaffoldViewController.view animated:YES];
    [self loadSequence:sequenceID completion:^(NSError *_Nullable error)
     {
         if ( error == nil )
         {
             [hud hide:YES];
             
             id<PersistentStoreType> persistentStore = [PersistentStoreSelector defaultPersistentStore];
             [persistentStore.mainContext performBlockAndWait:^
              {
                  NSArray *objects = [persistentStore.mainContext v_findObjectsWithEntityName:[VSequence entityName]
                                                                            queryDictionary:@{ @"remoteId" : sequenceID }];
                  context.sequence = (VSequence *)[objects firstObject];
              }];
             [self.contentViewPresenter presentContentViewWithContext:context];
         }
         else
         {
             [hud hide:YES];
             completion( NO, nil );
         }
     }];
}

@end
