//
//  VPublishPresenter.m
//  victorious
//
//  Created by Michael Sena on 7/15/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPublishPresenter.h"

#import "VPublishViewController.h"
#import "VAlongsideTransitioner.h"

@interface VPublishPresenter ()

@property (nonatomic, weak) UIViewController *viewControllerPresentedOn;
@property (nonatomic, strong) VAlongsideTransitioner *transitioner;
@property (nonatomic, strong, readwrite) VPublishViewController *publishViewController;

@end

@implementation VPublishPresenter

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super initWithDependencyManager:dependencyManager];
    if (self != nil)
    {
        _transitioner = [[VAlongsideTransitioner alloc] init];
        _publishViewController = [dependencyManager newPublishViewController];
        _publishViewController.transitioningDelegate = _transitioner;
        _publishViewController.modalPresentationStyle = UIModalPresentationCustom;
    }
    return self;
}

#pragma mark - VAbstractPresenter

- (void)presentOnViewController:(UIViewController *)viewControllerToPresentOn
{
    self.viewControllerPresentedOn = viewControllerToPresentOn;
    [viewControllerToPresentOn presentViewController:self.publishViewController
                                            animated:YES
                                          completion:nil];
}

#pragma mark - PropertyAccessors

- (void)setPublishParameters:(VPublishParameters *)publishParameters
{
    self.publishViewController.publishParameters = publishParameters;
}

- (VPublishParameters *)publishParameters
{
    return self.publishViewController.publishParameters;
}

- (void)setPublishActionHandler:(void (^)(BOOL))publishActionHandler
{
    NSParameterAssert(publishActionHandler != nil);
    _publishActionHandler = [publishActionHandler copy];
    
    __weak typeof(self) welf = self;
    self.publishViewController.completion = ^void(BOOL success)
    {
        __strong typeof(welf) strongSelf = welf;
        strongSelf.publishViewController.completion = nil;
        if (strongSelf.publishActionHandler != nil)
        {
            strongSelf.publishActionHandler(success);
        }
    };
}

@end
