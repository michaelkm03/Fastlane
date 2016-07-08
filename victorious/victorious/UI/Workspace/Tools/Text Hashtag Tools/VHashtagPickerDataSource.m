//
//  VHashtagPickerDataSource.m
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHashtagPickerDataSource.h"
#import "VHashtagOptionCell.h"
#import "VWorkspaceTool.h"
#import "VDependencyManager.h"
#import "VHashtagType.h"
#import "NSArray+VMap.h"
#import "VHashtags.h"
#import "victorious-Swift.h"

@interface VHashtagPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagPickerDataSource

@synthesize tools;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if ( self != nil )
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (id<VWorkspaceTool>)toolForHashtag:(NSString *)hashtagText
{
    for ( VHashtagType<VWorkspaceTool> *tool in self.tools )
    {
        NSString *textWithoutHashmark = [tool.hashtagText stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if ( [tool isKindOfClass:[VHashtagType class]] && [textWithoutHashmark isEqualToString:hashtagText] )
        {
            return tool;
        }
    }
    
    return nil;
}

- (void)registerCellsWithCollectionView:(UICollectionView *)collectionView
{
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    NSBundle *bundle = [NSBundle bundleForClass:[VHashtagOptionCell class]];
    [collectionView registerNib:[UINib nibWithNibName:identifier bundle:bundle] forCellWithReuseIdentifier:identifier];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tools.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [VHashtagOptionCell suggestedReuseIdentifier];
    VHashtagType *hashtagType = self.tools[ indexPath.row ];
    VHashtagOptionCell *hashtagCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    hashtagCell.font = [self.dependencyManager fontForKey:@"font.button"];
    hashtagCell.selectedColor = [self.dependencyManager colorForKey:@"color.link"];
    hashtagCell.selected = [((id<VMultipleToolPicker>)self.toolPicker) toolIsSelectedAtIndex:indexPath.row];
    if ( hashtagCell.selected )
    {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:0];
    }
    hashtagCell.title = hashtagType.hashtagText;
    return hashtagCell;
}

- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion
{
    TrendingHashtagOperation *operation = [[TrendingHashtagOperation alloc] init];
    [operation queueWithCompletion:^(NSArray *_Nullable results, NSError *_Nullable error, BOOL cancelled)
    {
        if (error == nil)
        {
            NSArray *hashtagTools = [operation.results v_map:^VHashtagType *(HashtagSearchResultObject *hashtag)
            {
                return [[VHashtagType alloc] initWithHashtagText:[VHashTags stringWithPrependedHashmarkFromString:hashtag.tag]];
            }];
            
            if ( completion != nil )
            {
                completion( hashtagTools );
            }
        }
        else
        {
            if ( completion != nil )
            {
                completion( nil );
            }
        }
    }];
}

@end
