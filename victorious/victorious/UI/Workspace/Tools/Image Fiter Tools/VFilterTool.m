//
//  VFilterTool.m
//  victorious
//
//  Created by Michael Sena on 12/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VFilterTool.h"
#import "VToolPicker.h"
#import "VFilterTypeTool.h"

#import "NSArray+VMap.h"
#import "VCanvasView.h"

#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

// Filters
#import "VPhotoFilterSerialization.h"

#import "VFilterPickerDataSource.h"

static NSString * const kTitleKey = @"title";
static NSString * const kPickerKey = @"picker";
static NSString * const kFilterIndexKey = @"filterIndex";
static NSString * const kIconKey = @"icon";
static NSString * const kSelectedIconKey = @"selectedIcon";

@interface VFilterTool () <VToolPickerDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIViewController <VToolPicker> *toolPicker;
@property (nonatomic, strong) VFilterTypeTool *selectedFilter;
@property (nonatomic, strong) VCanvasView *canvasView;

@end

@implementation VFilterTool

@synthesize renderIndex = _renderIndex;
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
        _toolPicker = (UIViewController<VToolPicker> *)[dependencyManager viewControllerForKey:kPickerKey];
        _icon = [dependencyManager imageForKey:kIconKey];
        _selectedIcon = [dependencyManager imageForKey:kSelectedIconKey];
        
        NSURL *filterFileURL = [[NSBundle mainBundle] URLForResource:@"filters" withExtension:@"xml"];
        NSArray *photoFilters = [VPhotoFilterSerialization filtersFromPlistFile:filterFileURL];
        
        photoFilters = [photoFilters sortedArrayUsingComparator:^NSComparisonResult(VPhotoFilter *filter1, VPhotoFilter *filter2)
        {
            return [filter1.name caseInsensitiveCompare:filter2.name];
        }];
        
        VPhotoFilter *noFilterFilter = [[VPhotoFilter alloc] init];
        noFilterFilter.name = NSLocalizedString(@"#nofilter", @"No Filter filter name.");
        NSMutableArray *mutablePhotoFilters = [[NSMutableArray alloc] initWithArray:photoFilters];
        [mutablePhotoFilters insertObject:noFilterFilter atIndex:0];
        
        photoFilters = [mutablePhotoFilters copy];
        
        NSArray *filterTools = [photoFilters v_map:^id(VPhotoFilter *photoFilter)
        {
            VFilterTypeTool *imageFilter = [[VFilterTypeTool alloc] init];
            photoFilter.name = [photoFilter.name uppercaseString];
            imageFilter.filter = photoFilter;
            return imageFilter;
        }];
        
        id<VToolPickerDataSource> dataSource = [[VFilterPickerDataSource alloc] initWithDependencyManager:dependencyManager];
        dataSource.tools = filterTools;
        _toolPicker.dataSource = dataSource;
        _toolPicker.delegate = self;
    }
    return self;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@, title: %@, icon: %@", [super description], self.title, self.icon];
}

#pragma mark - Public Methods

- (NSString *)filterTitle
{
    NSString *filterTitle = nil;
    if ([self.toolPicker.selectedTool respondsToSelector:@selector(title)])
    {
        filterTitle = [self.toolPicker.selectedTool title];
    }
    return filterTitle;
}

#pragma mark - VWorkspaceTool

- (CIImage *)imageByApplyingToolToInputImage:(CIImage *)inputImage
{
    return self.selectedFilter ? [self.selectedFilter.filter filteredImageWithInputImage:inputImage] : inputImage;
}

- (void)setCanvasView:(VCanvasView *)canvasView
{
    _canvasView = canvasView;
}

- (void)toolPicker:(id<VToolPicker>)toolPicker didSelectItemAtIndex:(NSInteger)index
{
    VFilterTypeTool<VWorkspaceTool> *selectedTool = [toolPicker.dataSource.tools objectAtIndex:index];
    
    self.canvasView.filter = selectedTool.filter;
    self.selectedFilter = selectedTool;
}

- (UIViewController *)inspectorToolViewController
{
    return (UIViewController *)self.toolPicker;
}

@end

