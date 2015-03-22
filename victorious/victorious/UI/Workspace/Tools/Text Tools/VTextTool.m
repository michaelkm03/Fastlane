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
#import "VDependencyManager+VWorkspaceTool.h"

// Rendering
#import "CIImage+VImage.h"

static NSString * const kTitleKey = @"title";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";
static NSString * const kSubtoolsKey = @"subtools";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";

@interface VTextTool ()

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger renderIndex;
@property (nonatomic, strong) NSArray *subTools;
@property (nonatomic, strong) id <VWorkspaceTool> activeTextTool;
@property (nonatomic, strong) VTickerPickerViewController *toolPicker;
@property (nonatomic, strong) VTextToolViewController *canvasToolViewController;

@end

@implementation VTextTool

@synthesize selected = _selected;
@synthesize selectedIcon = _selectedIcon;
@synthesize icon = _icon;

#pragma mark - VHasManagedDependancies

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _title = [dependencyManager stringForKey:kTitleKey];
        _subTools = [[dependencyManager workspaceTools] sortedArrayUsingComparator:^NSComparisonResult(id <VWorkspaceTool> tool1, id <VWorkspaceTool> tool2)
        {
            return [tool1.title caseInsensitiveCompare:tool2.title];
        }];
        
        _renderIndex = [[dependencyManager numberForKey:kFilterIndexKey] integerValue];
        _toolPicker = (VTickerPickerViewController *)[dependencyManager viewControllerForKey:kPickerKey];
        if ([_toolPicker respondsToSelector:@selector(setConfigureItemLabel:)])
        {
            _toolPicker.configureItemLabel = ^void(UILabel *label, VTextTypeTool *textToolType)
            {
                UIFont *adjustedFont = [(UIFont *)textToolType.attributes[NSFontAttributeName] fontWithSize:label.font.pointSize];
                NSMutableDictionary *mutableAttributes = [[NSMutableDictionary alloc] initWithDictionary:textToolType.attributes];
                mutableAttributes[NSFontAttributeName] = adjustedFont;
                label.attributedText = [[NSAttributedString alloc] initWithString:[textToolType.title uppercaseString]
                                                                       attributes:mutableAttributes];
            };
        }
        _canvasToolViewController = [VTextToolViewController textToolViewController];
        _icon = [dependencyManager imageForKey:kIconKey];
        _selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
        [_toolPicker setTools:_subTools];
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
    
    CIImage *textImage = [CIImage v_imageWithUImage:self.canvasToolViewController.renderedImage];
    
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

- (UIViewController *)inspectorToolViewController
{
    __weak typeof(self) welf = self;
    self.toolPicker.onToolSelection = ^(id <VWorkspaceTool> selectedTool)
    {
        BOOL activeToolWasUndefined = welf.activeTextTool == nil;
        
        welf.activeTextTool = selectedTool;
        
        // The first time the tool is selected, it is the default selection, not a user action
        if ( !activeToolWasUndefined )
        {
            NSDictionary *params = @{ VTrackingKeyName : selectedTool.title ?: @"" };
            [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectWorkspaceTextType parameters:params];
        }
    };
    return (UIViewController *)self.toolPicker;
}

@end
