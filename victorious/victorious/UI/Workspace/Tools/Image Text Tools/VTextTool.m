//
//  VTextTool.m
//  victorious
//
//  Created by Michael Sena on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTextTool.h"

// Picker
#import "VTickerPickerViewController.h"

// Interface
#import "VTextToolViewController.h"

// Depenedency Management
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspace.h"

// Rendering
#import "CIImage+VImage.h"

#import "VTextTypePickerDataSource.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VTextTool () <VToolPickerDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger renderIndex;
@property (nonatomic, strong) id <VWorkspaceTool> activeTextTool;
@property (nonatomic, strong) VTickerPickerViewController *toolPicker;
@property (nonatomic, strong) VTextToolViewController *canvasToolViewController;
@property (nonatomic, strong) VTextTypePickerDataSource *pickerDataSource;

@end

@implementation VTextTool

@synthesize selected = _selected;
@synthesize selectedIcon = _selectedIcon;
@synthesize icon = _icon;

#pragma mark - VHasManagedDependencies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _renderIndex = [[dependencyManager numberForKey:kFilterIndexKey] integerValue];
        _toolPicker = (VTickerPickerViewController *)[dependencyManager viewControllerForKey:kPickerKey];
        _pickerDataSource = [[VTextTypePickerDataSource alloc] initWithDependencyManager:dependencyManager];
        _toolPicker.dataSource = _pickerDataSource;
        _toolPicker.pickerDelegate = self;
        _canvasToolViewController = [VTextToolViewController textToolViewController];
        _icon = [dependencyManager imageForKey:kIconKey];
        _selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
    }
    return self;
}

#pragma mark - Property Accessors

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    self.canvasToolViewController.view.userInteractionEnabled = selected;
}

- (void)setActiveTextTool:(id<VWorkspaceTool>)activeTextTool
{
    if (activeTextTool == _activeTextTool)
    {
        return;
    }
    
    _activeTextTool = activeTextTool;
    
    if ([activeTextTool isKindOfClass:[VTextTypeTool class]])
    {
        self.canvasToolViewController.textType = (VTextTypeTool *)activeTextTool;
    }
}

- (NSString *)embeddedText
{
    return self.canvasToolViewController.embeddedText;
}

- (NSString *)textStyleTitle
{
    if ([self.toolPicker.selectedTool respondsToSelector:@selector(title)])
    {
        return [self.toolPicker.selectedTool title];
    }
    return nil;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    if (self.canvasToolViewController.renderedImage == nil)
    {
        return inputImage;
    }
    
    CIImage *textImage = [CIImage v_imageWithUIImage:self.canvasToolViewController.renderedImage];
    if ( textImage == nil )
    {
        return inputImage;
    }
    
    // Apply scale
    CGFloat widthScaleFactor = textImage.extent.size.width / inputImage.extent.size.width;
    CGFloat heightScaleFactor = textImage.extent.size.height / inputImage.extent.size.height;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(widthScaleFactor, heightScaleFactor);
    
    CIFilter *transformScaleFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformScaleFilter setValue:[NSValue valueWithBytes:&scaleTransform
                                                  objCType:@encode(CGAffineTransform)]
                            forKey:kCIInputTransformKey];
    [transformScaleFilter setValue:inputImage
                            forKey:kCIInputImageKey];
    
    // Adjust origin
    CGFloat originXDelta = textImage.extent.origin.x - [transformScaleFilter outputImage].extent.origin.x;
    CGFloat originYDelta = textImage.extent.origin.y - [transformScaleFilter outputImage].extent.origin.y;
    CGAffineTransform originTransofrm = CGAffineTransformMakeTranslation(originXDelta, originYDelta);
    CIFilter *transformOriginFilter = [CIFilter filterWithName:@"CIAffineTransform"];
    [transformOriginFilter setValue:[NSValue valueWithBytes:&originTransofrm
                                                  objCType:@encode(CGAffineTransform)]
                            forKey:kCIInputTransformKey];
    [transformOriginFilter setValue:[transformScaleFilter outputImage]
                            forKey:kCIInputImageKey];
    
    // Composite
    CIFilter *compositionFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
    [compositionFilter setValue:[transformOriginFilter outputImage]
                         forKey:kCIInputBackgroundImageKey];
    [compositionFilter setValue:textImage
                         forKey:kCIInputImageKey];
    
    return [compositionFilter outputImage];
}

- (NSInteger)renderIndex
{
    return _renderIndex;
}

- (BOOL)shouldLeaveToolOnCanvas
{
    return self.canvasToolViewController.userEnteredText;
}

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectTool:(id<VWorkspaceTool>)tool
{
    BOOL activeToolWasUndefined = self.activeTextTool == nil;
    
    self.activeTextTool = tool;
    
    // The first time the tool is selected, it is the default selection, not a user action
    if ( !activeToolWasUndefined )
    {
        NSDictionary *params = @{ VTrackingKeyName : self.activeTextTool.title ?: @"" };
        [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectWorkspaceTextType parameters:params];
    }
}

- (UIViewController *)inspectorToolViewController
{
    return (UIViewController *)self.toolPicker;
}

@end
