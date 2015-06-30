//
//  VImageVideoLibraryViewController.m
//  victorious
//
//  Created by Michael Sena on 6/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VImageVideoLibraryViewController.h"

// Views + Helpers
#import "VFlexBar.h"
#import "VCompatibility.h"

@interface VImageVideoLibraryViewController () <UIPopoverPresentationControllerDelegate>

@property (strong, nonatomic) IBOutlet VFlexBar *alternateCaptureOptionsFlexBar;

@end

@implementation VImageVideoLibraryViewController

#pragma mark - VHasManagedDependencies

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *storyboardForImageVideoGallery = [UIStoryboard storyboardWithName:NSStringFromClass(self)
                                                                             bundle:[NSBundle bundleForClass:self]];
    return [storyboardForImageVideoGallery instantiateInitialViewController];
}

#pragma mark - View Lifecycle

- (void)viewDidLayoutSubviews
{
    CGFloat fullWidth = CGRectGetWidth(self.view.bounds);
    if (self.alternateCaptureOptions.count > 0)
    {
        CGFloat widthPerElement = VFLOOR(fullWidth / self.alternateCaptureOptions.count);
        
        for (VImageLibraryAlternateCaptureOption *alternateOption in self.alternateCaptureOptions)
        {
            // add buttons to flex bar
        }
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"albumsPopover"])
    {
        // Set delegate to self so we can show as a real popover (Non-adaptive).
        UIViewController *destinationViewController = segue.destinationViewController;
        destinationViewController.popoverPresentationController.delegate = self;
        // Inset the popover a bit
        CGSize preferredContentSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - 50.0f,
                                                 CGRectGetHeight(self.view.bounds) - 200.0f);
        destinationViewController.preferredContentSize = preferredContentSize;
    }
}

#pragma mark - UIPopoverPresentationControllerDelegate

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
                                                               traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

@end

#pragma mark - VImageLibraryAlternateCaptureOption

@interface VImageLibraryAlternateCaptureOption ()

@property (nonatomic, copy) VImageLibraryAlternateCaptureOption *selectionBlock;

@end

@implementation VImageLibraryAlternateCaptureOption

- (instancetype)initWithTitle:(NSString *)title
                         icon:(UIImage *)icon
            andSelectionBlock:(VImageVideoLibraryAlternateCaptureSelection)selectionBlock
{
    self = [super init];
    if (self != nil)
    {
        _title = title;
        _icon = icon;
        _selectionBlock = [selectionBlock copy];
    }
    return self;
}

@end
