//
//  VLoadingOverlayViewController.m
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VLoadingOverlayViewController.h"

@interface VLoadingOverlayViewController ()

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UILabel *Label;

@end

@implementation VLoadingOverlayViewController

+ (VLoadingOverlayViewController *)instantiateFromStoryboard:(NSString *)storyboardName
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:[NSBundle mainBundle]];
    NSString *identifier = NSStringFromClass( [[self class] class] );
    return [storyboard instantiateViewControllerWithIdentifier:identifier];;
}

- (void)configureForUseInViewController:(UIViewController *)viewController
{
    if ( viewController != nil && viewController.view != nil )
    {
        if ( ![self.view.superview isEqual:viewController.view]  )
        {
            [viewController.view addSubview:self.view];
            
            NSDictionary *views = @{ @"view" : self.view };
            NSArray *contraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|"
                                                                           options:kNilOptions
                                                                           metrics:nil
                                                                             views:views];
            NSArray *contraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|"
                                                                           options:kNilOptions
                                                                           metrics:nil
                                                                             views:views];
            [self.view.superview addConstraints:contraintsH];
            [self.view.superview addConstraints:contraintsV];
        }
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.view.hidden = YES;
    self.container.layer.cornerRadius = 5.0f;
}

- (void)showWithText:(NSString *)text animated:(BOOL)animated
{
    self.Label.text = text;
    self.view.hidden = NO;
}

- (void)hideAnimated:(BOOL)animated
{
    self.Label.text = @"";
    self.view.hidden = YES;
}

@end
