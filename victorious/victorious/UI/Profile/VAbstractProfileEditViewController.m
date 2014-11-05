//
//  VProfileEditViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAbstractProfileEditViewController.h"
#import "VCameraViewController.h"
#import "VUser.h"
#import "UIImageView+Blurring.h"
#import "UIImage+ImageEffects.h"
#import "VThemeManager.h"

@implementation VAbstractProfileEditViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.usernameTextField.delegate = self;
    self.locationTextField.delegate = self;
    self.taglineTextView.delegate = self;
    
    self.profileImageView.layer.masksToBounds = YES;
    self.profileImageView.layer.cornerRadius = CGRectGetHeight(self.profileImageView.bounds)/2;
    self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.profileImageView.layer.shouldRasterize = YES;
    self.profileImageView.clipsToBounds = YES;
    
    self.cameraButton.layer.masksToBounds = YES;
    self.cameraButton.layer.cornerRadius = CGRectGetHeight(self.cameraButton.bounds)/2;
    self.cameraButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.cameraButton.layer.shouldRasterize = YES;
    self.cameraButton.clipsToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.usernameTextField.text = self.profile.name;
    self.taglineTextView.text = self.profile.tagline;
    self.locationTextField.text = self.profile.location;
    if ([self respondsToSelector:@selector(textViewDidChange:)])
    {
        [self textViewDidChange:self.taglineTextView];
    }
    
    UIImage    *backgroundImage = [[[VThemeManager sharedThemeManager] themedBackgroundImageForDevice]
                                   applyBlurWithRadius:0 tintColor:[UIColor colorWithWhite:0.0 alpha:0.3] saturationDeltaFactor:1.8 maskImage:nil];
    
    NSURL  *imageURL    =   [NSURL URLWithString:self.profile.pictureUrl];
    [self.profileImageView setImageWithURL:imageURL placeholderImage:backgroundImage];
    
    //  Set background image
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.tableView.backgroundView.frame];
    [backgroundImageView setBlurredImageWithURL:[NSURL URLWithString:self.profile.pictureUrl]
                               placeholderImage:[UIImage imageNamed:@"profileGenericUser"]
                                      tintColor:[UIColor colorWithWhite:1.0 alpha:0.3]];
    
    self.tableView.backgroundView = backgroundImageView;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[self view] endEditing:YES];
}

#pragma mark - Actions

- (IBAction)takePicture:(id)sender
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    VCameraViewController *cameraViewController = [VCameraViewController cameraViewControllerLimitedToPhotos];
    cameraViewController.completionBlock = ^(BOOL finished, UIImage *previewImage, NSURL *capturedMediaURL)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        if (finished && capturedMediaURL)
        {
            self.profileImageView.image = previewImage;
            self.updatedProfileImage = capturedMediaURL;
        }
    };
    [navigationController pushViewController:cameraViewController animated:NO];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField setTintColor:[UIColor blueColor]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.usernameTextField])
    {
        [self.locationTextField becomeFirstResponder];
    }
    else if ([textField isEqual:self.locationTextField])
    {
        [self.locationTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == self.taglineTextView)
    {
        CGPoint point = self.tableView.contentOffset;
        point.y += self.tableView.rowHeight;
        
        [UIView animateWithDuration:.5 animations:^{
            self.tableView.contentOffset = point;
            [textView setTintColor:[UIColor blueColor]];
        }];
        
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.tagLinePlaceholderLabel.hidden = ([textView.text length] > 0);
    CGPoint point = self.tableView.contentOffset;
    point.y -= self.tableView.rowHeight;
    
    [UIView animateWithDuration:.5 animations:^{
        self.tableView.contentOffset = point;
    }];
}

@end
