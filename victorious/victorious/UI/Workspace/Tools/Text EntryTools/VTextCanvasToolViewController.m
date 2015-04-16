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
@property (nonatomic, weak) IBOutlet UIButton *buttonClear;

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

    for ( UIButton *button in @[ self.buttonCamera, self.buttonClear, self.buttonImageSearch ] )
    {
        button.layer.cornerRadius = CGRectGetWidth(self.buttonCamera.frame) * 0.5;
        button.backgroundColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    }
    
    [self setShouldProvideClearOption:NO animated:NO];
    
    self.textPostViewController = [VEditableTextPostViewController newWithDependencyManager:self.dependencyManager];
    [self addChildViewController:self.textPostViewController];
    [self.textPostViewController willMoveToParentViewController:self];
    [self.view insertSubview:self.textPostViewController.view atIndex:0];
    [self.view v_addFitToParentConstraintsToSubview:self.textPostViewController.view];
    [self.textPostViewController didMoveToParentViewController:self];
}

- (void)setShouldProvideClearOption:(BOOL)shouldProvideClearOption
{
    [self setShouldProvideClearOption:shouldProvideClearOption animated:YES];
}

- (void)setShouldProvideClearOption:(BOOL)shouldProvideClearOption animated:(BOOL)animated
{
    _shouldProvideClearOption = shouldProvideClearOption;
    
    // Prevent the animation from re-playing if this is called again
    if ( _shouldProvideClearOption && self.buttonClear.hidden == NO )
    {
        return;
    }
    
    if ( shouldProvideClearOption )
    {
        self.buttonClear.hidden = NO;
    }
    
    CGFloat startScale = shouldProvideClearOption ? 0.0f : 1.0f;
    self.buttonClear.transform = CGAffineTransformMakeScale( startScale, startScale );
    
    void (^animations)() = ^void
    {
        CGFloat endScale = shouldProvideClearOption ? 1.0f : 0.01f;
        self.buttonClear.transform = CGAffineTransformMakeScale( endScale, endScale );
    };
    
    void (^completion)(BOOL) = ^void (BOOL finished)
    {
        if ( !shouldProvideClearOption )
        {
            self.buttonClear.hidden = YES;
        }
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:shouldProvideClearOption ? 0.75f : 0.35f
                              delay:shouldProvideClearOption ? 0.75f : 0.0f
             usingSpringWithDamping:shouldProvideClearOption ? 0.5f : 1.0f
              initialSpringVelocity:shouldProvideClearOption ? 0.5f : 0.0f
                            options:shouldProvideClearOption ? kNilOptions : UIViewAnimationOptionCurveEaseOut
                         animations:animations
                         completion:completion];
    }
    else
    {
        animations();
        completion( YES );
    }
}

- (IBAction)backgroundImageCameraSelected:(id)sender
{
    [self.delegate textCanvasToolDidSelectCamera:self];
}

- (IBAction)backgroundImageSearchSelected:(id)sender
{
    [self.delegate textCanvasToolDidSelectImageSearch:self];
}

- (IBAction)backgroundImageClearSelected:(id)sender
{
    [self.delegate textCanvasToolDidSelectClearImage:self];
}

@end
