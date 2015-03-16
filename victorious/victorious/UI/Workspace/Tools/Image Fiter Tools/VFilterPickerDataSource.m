//
//  VFilterPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VFilterPickerDataSource.h"
#import "VBasicToolPickerCell.h"
#import "VWorkspaceTool.h"
#import "VTextTypeTool.h"
#import "VDependencyManager.h"

@interface VFilterPickerDataSource ()

@property (nonatomic, strong) NSArray *tools;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VFilterPickerDataSource

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager tools:(NSArray *)tools
{
    self = [super init];
    if (self)
    {
        _tools = tools;
        _dependencyManager = dependencyManager;
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
    return (NSInteger)self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VBasicToolPickerCell *pickerCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VBasicToolPickerCell suggestedReuseIdentifier]
                                                                                 forIndexPath:indexPath];
    VTextTypeTool *textToolType = (VTextTypeTool *)self.tools[ indexPath.row ];
    
    UIFont *adjustedFont = [(UIFont *)textToolType.attributes[NSFontAttributeName] fontWithSize:pickerCell.label.font.pointSize];
    NSMutableDictionary *mutableAttributes = [[NSMutableDictionary alloc] initWithDictionary:textToolType.attributes];
    mutableAttributes[NSFontAttributeName] = adjustedFont;
    pickerCell.label.attributedText = [[NSAttributedString alloc] initWithString:[textToolType.title uppercaseString]
                                                                      attributes:mutableAttributes];
    
#warning make sure we don't need this anymore
   /* if (self.configureItemLabel != nil)
    {
        self.configureItemLabel(pickerCell.label, toolForIndexPath);
    }
    else
    {
        pickerCell.label.text = toolForIndexPath.title;
        pickerCell.label.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    }*/
    
    return pickerCell;
}

@end
