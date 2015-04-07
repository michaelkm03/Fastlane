//
//  VContentDeepLinkHandler.m
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VObjectManager+Sequence.h"
#import "VDependencyManager+VObjectManager.h"
#import "VContentDeepLinkHandler.h"
#import "VScaffoldViewController.h"
#import <MBProgressHUD.h>
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
        NSParameterAssert( dependencyManager != nil );
        NSParameterAssert( [self.dependencyManager objectManager] != nil );
                              
        _scaffoldViewController = [dependencyManager scaffoldViewController];
        NSParameterAssert( _scaffoldViewController != nil );
    }
    return self;
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

- (BOOL)displayContentForDeeplinkURL:(NSURL *)url completion:(VDeeplinkHandlerCompletionBlock)completion
{
    if ( ![self canDisplayContentForDeeplinkURL:url] )
    {
        return NO;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.scaffoldViewController.view animated:YES];
    
    NSString *sequenceID = [url v_firstNonSlashPathComponent];
    
    NSNumber *commentId = nil;
    NSString *commentIDString = [url v_pathComponentAtIndex:2];
    if ( commentIDString != nil )
    {
        commentId = @([commentIDString integerValue]);
    }
    
    [[self.dependencyManager objectManager] fetchSequenceByID:sequenceID
                                                 successBlock:^(NSOperation *operation, id fullResponse, NSArray *resultObjects)
     {
         [hud hide:YES];
         VSequence *sequence = (VSequence *)[resultObjects firstObject];
         [self.scaffoldViewController showContentViewWithSequence:sequence commentId:commentId placeHolderImage:nil];
     }
                                                    failBlock:^(NSOperation *operation, NSError *error)
     {
         [hud hide:YES];
         VLog(@"Failed with error: %@", error);
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Content", nil)
                                                         message:NSLocalizedString(@"Missing Content Message", nil)
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                               otherButtonTitles:nil];
         [alert show];
     }];
    
    return YES;
}

@end
