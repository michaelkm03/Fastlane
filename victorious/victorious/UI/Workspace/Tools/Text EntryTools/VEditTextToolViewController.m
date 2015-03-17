//
//  VEditTextToolViewController.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VEditTextToolViewController.h"
#import "VDependencyManager.h"
#import "UIView+AutoLayout.h"

@interface VEditTextToolViewController () <UITextViewDelegate>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, weak) IBOutlet UIButton *buttonImageSearch;
@property (nonatomic, weak) IBOutlet UIButton *buttonCamera;

@property (nonatomic, strong, readwrite) VTextPostViewController *textPostViewController;

@end

@implementation VEditTextToolViewController

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *nibName = NSStringFromClass([self class]);
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    VEditTextToolViewController *viewController = [[VEditTextToolViewController alloc] initWithNibName:nibName bundle:bundle];
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
    
    self.textPostViewController = [VTextPostViewController newWithDependencyManager:self.dependencyManager];
    [self.view insertSubview:self.textPostViewController.view atIndex:0];
    [self.view v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    
    self.buttonImageSearch.alpha = 0.0f;
    self.buttonCamera.alpha = 0.0f;
    
    [self.textPostViewController performSelector:@selector(startEditingText) withObject:nil afterDelay:0.0f];
    
    self.textPostViewController.supplementaryHashtagText = @"#SampleHashtag";
}

- (void)setImageControlsVisible:(BOOL)visible animated:(BOOL)animated
{
    [UIView animateWithDuration:1.5f
                          delay:0.0f
         usingSpringWithDamping:0.5f
          initialSpringVelocity:0.5f
                        options:kNilOptions animations:^
     {
         self.buttonImageSearch.alpha = visible ? 1.0f : 0.0f;
         self.buttonCamera.alpha = visible ? 1.0f : 0.0f;
     }
                     completion:nil];
}

@end
