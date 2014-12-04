//
//  VWorkspaceViewController.m
//  victorious
//
//  Created by Michael Sena on 12/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWorkspaceViewController.h"

// Dependency Management
#import "VDependencyManager+VWorkspaceTool.h"

// Views
#import <MBProgressHUD/MBProgressHUD.h>

#import "VWorkspaceTool.h"
#import "VCategoryWorkspaceTool.h"

@interface VWorkspaceViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSArray *tools;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet UIView *canvasView;

@property (nonatomic, strong) id <VWorkspaceTool> selectedTool;
@property (nonatomic, strong) UIViewController *toolViewController;

@end

@implementation VWorkspaceViewController

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    UIStoryboard *workspaceStoryboard = [UIStoryboard storyboardWithName:@"Workspace" bundle:nil];
    VWorkspaceViewController *workspaceViewController = [workspaceStoryboard instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    workspaceViewController.dependencyManager = dependencyManager;
    workspaceViewController.tools = [dependencyManager tools];
    return workspaceViewController;
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSMutableArray *toolBarItems = [[NSMutableArray alloc] init];
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    [self.tools enumerateObjectsUsingBlock:^(id <VWorkspaceTool> tool, NSUInteger idx, BOOL *stop)
    {
        UIBarButtonItem *itemForTool = [[UIBarButtonItem alloc] initWithTitle:tool.title
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(toolSelected:)];
        itemForTool.tintColor = [UIColor whiteColor];
        [toolBarItems addObject:itemForTool];
        itemForTool.tag = idx;
    }];
    
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.bottomToolbar.items = toolBarItems;
}

#pragma mark - Target/Action

- (IBAction)close:(id)sender
{
    self.completionBlock(NO, nil);
}

- (IBAction)publish:(id)sender
{
    MBProgressHUD *hudForView = [MBProgressHUD showHUDAddedTo:self.view
                                                     animated:YES];
    hudForView.labelText = @"Publishing...";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        [MBProgressHUD hideHUDForView:self.view
                             animated:YES];
        self.completionBlock(YES, nil);
    });
}

- (void)toolSelected:(UIBarButtonItem *)sender
{
    [self setSelectedBarButtonItem:sender];
    
    id <VWorkspaceTool> selectedTool = [self toolForTag:sender.tag];
    
    // Re-selected current tool should we dismiss?
    if (selectedTool == self.selectedTool)
    {
        return;
    }
    
    self.selectedTool = selectedTool;
    
    // Hide picker if any
    if (self.toolViewController)
    {
        [self.toolViewController willMoveToParentViewController:nil];
        [self.toolViewController.view removeFromSuperview];
        [self.toolViewController didMoveToParentViewController:nil];
    }

    [self showToolViewControllerForTool:self.selectedTool];
}

#pragma mark - Private Methods

- (void)setSelectedBarButtonItem:(UIBarButtonItem *)itemToSelect
{
    [self.bottomToolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem *item, NSUInteger idx, BOOL *stop) {
        item.tintColor = [UIColor whiteColor];
    }];
    itemToSelect.tintColor = [UIColor magentaColor];
}

- (id <VWorkspaceTool>)toolForTag:(NSInteger)tag
{
    if ((self.tools.count == 0) && ((NSInteger)self.tools.count < tag))
    {
        return nil;
    }
    return self.tools[tag];
}

- (void)showToolViewControllerForTool:(id<VWorkspaceTool>)tool
{
    if ([tool toolViewController] == nil)
    {
        return;
    }
    
    self.toolViewController = [tool toolViewController];
    [self addChildViewController:self.toolViewController];
    [self.view addSubview:self.toolViewController.view];
    [self.toolViewController didMoveToParentViewController:self];
    self.toolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    switch (self.selectedTool.toolLocation)
    {
        case VWorkspaceToolLocationInspector:
        {
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:@{@"picker":self.toolViewController.view}]];
            NSDictionary *verticalMetrics = @{@"toolbarHeight":@(CGRectGetHeight(self.bottomToolbar.bounds))};
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[canvas][picker]-toolbarHeight-|"
                                                                              options:kNilOptions
                                                                              metrics:verticalMetrics
                                                                                views:@{@"picker":self.toolViewController.view,
                                                                                        @"canvas":self.canvasView}]];
        }
            break;
        case VWorkspaceToolLocationCanvas:
        {
            NSDictionary *viewMap = @{@"canvas": self.canvasView,
                                      @"toolInterface": self.toolViewController.view};
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[toolInterface(==canvas)]"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:viewMap]];
            [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolInterface(==canvas)]"
                                                                              options:kNilOptions
                                                                              metrics:nil
                                                                                views:viewMap]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolViewController.view
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.canvasView
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.toolViewController.view
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.canvasView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
        }
            break;
    }

}

@end
