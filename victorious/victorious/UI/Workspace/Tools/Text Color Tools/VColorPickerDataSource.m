//
//  VColorPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VColorPickerDataSource.h"
#import "VDependencyManager.h"
#import "VColorOptionCell.h"
#import "VColorType.h"
#import "NSArray+VMap.h"

static NSString * const kColorOptionsKey = @"colorOptions";
static NSString * const kColorKey = @"color";
static NSString * const kTitleKey = @"title";

@interface VColorPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VColorPickerDataSource

@synthesize tools;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
        
        [self reloadWithCompletion:nil];
    }
    return self;
}

- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion
{
    NSArray *colorOptions = [_dependencyManager templateValueOfType:[NSArray class] forKey:@"colorOptions"];
    NSArray *suppliedColors = [colorOptions v_map:^VColorType *(NSDictionary *dictionary)
                               {
                                   NSString *title = dictionary[ kTitleKey ];
                                   UIColor *color = [VDependencyManager colorFromDictionary:dictionary[ kColorKey ]];
                                   if ( color != nil && title != nil )
                                   {
                                       return [[VColorType alloc] initWithColor:color title:title];
                                   }
                                   return nil;
                               }];
    UIColor *accentColor = [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
    if ( accentColor != nil )
    {
        VColorType *defaultColorOption = [[VColorType alloc] initWithColor:accentColor title:NSLocalizedString( @"Standard", nil)];
        suppliedColors = [@[ defaultColorOption ] arrayByAddingObjectsFromArray:suppliedColors];
    }
    
    if ( self.showNoColor )
    {
        VColorType *noColorOption = [[VColorType alloc] initWithColor:nil title:NSLocalizedString( @"No Color", nil)];
        suppliedColors = [suppliedColors arrayByAddingObject:noColorOption];
    }
    
    self.tools = suppliedColors;
    
    if ( completion != nil )
    {
        completion( self.tools );
    }
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VColorOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VColorOptionCell suggestedReuseIdentifier];
    VColorOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    VColorType *colorType = self.tools[ indexPath.row ];
    cell.font = [self.dependencyManager fontForKey:VDependencyManagerButton2FontKey];
    [cell setColor:colorType.color withTitle:colorType.title];
    
    return cell;
}

@end
