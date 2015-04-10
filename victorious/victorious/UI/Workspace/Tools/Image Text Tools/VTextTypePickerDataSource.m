//
//  VTextTypePickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextTypePickerDataSource.h"
#import "VBasicToolPickerCell.h"
#import "VTextTypeTool.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VWorkspaceTool.h"

@interface VTextTypePickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSArray *subTools;

@end

@implementation VTextTypePickerDataSource

@synthesize tools;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        self.tools = [[dependencyManager workspaceTools] sortedArrayUsingComparator:^NSComparisonResult(id <VWorkspaceTool> tool1, id <VWorkspaceTool> tool2)
                      {
                          return [tool1.title caseInsensitiveCompare:tool2.title];
                      }];
        
    }
    return self;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VBasicToolPickerCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VBasicToolPickerCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VBasicToolPickerCell suggestedReuseIdentifier];
    VBasicToolPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    VTextTypeTool *textToolType = (VTextTypeTool *)self.tools[ indexPath.row ];
    
    UIFont *adjustedFont = [(UIFont *)textToolType.attributes[NSFontAttributeName] fontWithSize:cell.label.font.pointSize];
    NSMutableDictionary *mutableAttributes = [[NSMutableDictionary alloc] initWithDictionary:textToolType.attributes];
    mutableAttributes[NSFontAttributeName] = adjustedFont;
    cell.label.attributedText = [[NSAttributedString alloc] initWithString:[NSLocalizedString(textToolType.title, @"") uppercaseStringWithLocale:[NSLocale currentLocale]]
                                                           attributes:mutableAttributes];
    return cell;
}

@end
