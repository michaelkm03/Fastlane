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
#import "VCanvasView.h"
#import <MBProgressHUD/MBProgressHUD.h>

// Protocols
#import "VWorkspaceTool.h"

// Tools
#import "VCropWorkspaceTool.h"
#import "VFilterWorkspaceTool.h"
#import "VTextWorkspaceTool.h"

@interface VWorkspaceViewController ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSArray *tools;
@property (nonatomic, weak) IBOutlet UIToolbar *bottomToolbar;
@property (weak, nonatomic) IBOutlet VCanvasView *canvasView;

@property (nonatomic, strong) id <VWorkspaceTool> selectedTool;
@property (nonatomic, strong) UIViewController *canvasToolViewController;
@property (nonatomic, strong) UIViewController *inspectorToolViewController;

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

- (void)dealloc
{
    
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
                                                                       action:@selector(selectedBarButtonItem:)];
        itemForTool.tintColor = [UIColor whiteColor];
        [toolBarItems addObject:itemForTool];
        itemForTool.tag = idx;
    }];
    
    [toolBarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    self.bottomToolbar.items = toolBarItems;
    
    self.canvasView.sourceImage = [UIImage imageNamed:@"spaceman.jpg"];
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

- (void)selectedBarButtonItem:(UIBarButtonItem *)sender
{
    [self setSelectedBarButtonItem:sender];
    
    self.selectedTool = (id <VWorkspaceTool>)[self toolForTag:sender.tag];
}

#pragma mark - Property Accessors

- (void)setSelectedTool:(id<VWorkspaceTool>)selectedTool
{
    // Re-selected current tool should we dismiss?
    if (selectedTool == _selectedTool)
    {
        return;
    }
 
 
    
    __weak typeof(self) welf = self;
    if ([selectedTool isKindOfClass:[VCropWorkspaceTool class]])
    {
        VCropWorkspaceTool *cropTool = (VCropWorkspaceTool *)selectedTool;
        
        [cropTool setAssetSize:self.canvasView.sourceImage.size];
        cropTool.onCropBoundsChange = ^void(UIScrollView *croppingScrollView)
        {
            [welf.canvasView.canvasScrollView setZoomScale:croppingScrollView.zoomScale];
            [welf.canvasView.canvasScrollView setContentOffset:croppingScrollView.contentOffset];
        };
    }
    else if ([selectedTool isKindOfClass:[VFilterWorkspaceTool class]])
    {
        VFilterWorkspaceTool *filterTool = (VFilterWorkspaceTool *)selectedTool;
        filterTool.onFilterChange = ^void(VPhotoFilter *filter)
        {
            welf.canvasView.filter = filter;
        };
    }
    
    if ([_selectedTool isKindOfClass:[VTextWorkspaceTool class]] && ![selectedTool isKindOfClass:[VTextWorkspaceTool class]])
    {
        _canvasToolViewController.view.userInteractionEnabled = NO;
        _canvasToolViewController = nil;
    }
    else
    {
        [selectedTool canvasToolViewController].view.userInteractionEnabled = YES;
    }
    
    if ([selectedTool respondsToSelector:@selector(setOnCanvasToolUpdate:)])
    {
        [selectedTool setOnCanvasToolUpdate:^
         {
             [welf setCanvasToolViewController:[welf.selectedTool canvasToolViewController]
                                       forTool:welf.selectedTool];
         }];
    }
    
    [self setCanvasToolViewController:[selectedTool canvasToolViewController]
                              forTool:selectedTool];
    [self setInspectorToolViewController:[selectedTool inspectorToolViewController]
                                 forTool:selectedTool];
    
   _selectedTool = selectedTool;
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

- (void)removeToolViewController:(UIViewController *)toolViewController
{
    [toolViewController willMoveToParentViewController:nil];
    [toolViewController.view removeFromSuperview];
    [toolViewController didMoveToParentViewController:nil];
}

- (void)addToolViewController:(UIViewController *)viewController
{
    [self addChildViewController:viewController];
    [self.view addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
}

- (void)setCanvasToolViewController:(UIViewController *)canvasToolViewController
                            forTool:(id<VWorkspaceTool>)tool
{
    [self removeToolViewController:self.canvasToolViewController];
    self.canvasToolViewController = canvasToolViewController;
    
    if (canvasToolViewController == nil)
    {
        return;
    }
    [self addToolViewController:canvasToolViewController];
    [self positionToolViewControllerOnCanvas:self.canvasToolViewController];
}

- (void)setInspectorToolViewController:(UIViewController *)inspectorToolViewController
                               forTool:(id<VWorkspaceTool>)tool
{
    [self removeToolViewController:self.inspectorToolViewController];
    self.inspectorToolViewController = inspectorToolViewController;
    
    if (inspectorToolViewController == nil)
    {
        return;
    }
    [self addToolViewController:inspectorToolViewController];
    [self positionToolViewControllerOnInspector:inspectorToolViewController];
}



- (void)positionToolViewControllerOnCanvas:(UIViewController *)toolViewController
{
    toolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewMap = @{@"canvas": self.canvasView,
                              @"toolInterface": toolViewController.view};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[toolInterface(==canvas)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolInterface(==canvas)]"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolViewController.view
                                                          attribute:NSLayoutAttributeLeft
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.canvasView
                                                          attribute:NSLayoutAttributeLeft
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:toolViewController.view
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.canvasView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)positionToolViewControllerOnInspector:(UIViewController *)toolViewController
{
    toolViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[picker]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:@{@"picker":toolViewController.view}]];
    NSDictionary *verticalMetrics = @{@"toolbarHeight":@(CGRectGetHeight(self.bottomToolbar.bounds))};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[canvas][picker]-toolbarHeight-|"
                                                                      options:kNilOptions
                                                                      metrics:verticalMetrics
                                                                        views:@{@"picker":toolViewController.view,
                                                                                @"canvas":self.canvasView}]];
}

@end
