//
//  VTextCanvasToolViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextCanvasToolViewController.h"
#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"
#import "VEditableTextPostViewController.h"

@interface VTextCanvasToolViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIButton *buttonImageSearch;
@property (nonatomic, weak) IBOutlet UIButton *buttonCamera;

@property (nonatomic, strong, readwrite) VEditableTextPostViewController *textPostViewController;

@end

@implementation VTextCanvasToolViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VTextCanvasToolViewController *viewController = [[VTextCanvasToolViewController alloc] initWithNibName:nibName bundle:bundle];
    viewController.dependencyManager = dependencyManager;
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.buttonCamera.layer.cornerRadius = CGRectGetWidth(self.buttonCamera.frame) * 0.5;
    self.buttonCamera.backgroundColor = [self.dependencyManager colorForKey:@"color.link"];
    self.buttonImageSearch.layer.cornerRadius = CGRectGetWidth(self.buttonImageSearch.frame) * 0.5;
    self.buttonImageSearch.backgroundColor = [self.dependencyManager colorForKey:@"color.link"];
    
    self.textPostViewController = [VEditableTextPostViewController newWithDependencyManager:self.dependencyManager];
    [self addChildViewController:self.textPostViewController];
    [self.textPostViewController willMoveToParentViewController:self];
    [self.view insertSubview:self.textPostViewController.view atIndex:0];
    [self.view v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    [self.textPostViewController didMoveToParentViewController:self];
    
    self.buttonImageSearch.alpha = 0.0f;
    self.buttonCamera.alpha = 0.0f;
}

@end
