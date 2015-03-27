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
#import "VObjectManager+Discover.h"
#import "NSArray+VMap.h"
#import "VHashtag.h"

@interface VHashtagPickerDataSource ()

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VHashtagPickerDataSource

@synthesize tools;

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (id<VWorkspaceTool>)toolForHashtag:(NSString *)hashtagText
{
    for ( VHashtagType<VWorkspaceTool> *tool in self.tools )
    {
        if ( [tool isKindOfClass:[VHashtagType class]] && [tool.hashtagText isEqualToString:hashtagText] )
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
    hashtagCell.title = hashtagType.hashtagText;
    return hashtagCell;
}

- (void)reloadWithCompletion:(void(^)(NSArray *tools))completion
{
    [[VObjectManager sharedManager] getSuggestedHashtags:^(NSOperation *operation, id result, NSArray *resultObjects)
     {
         NSArray *hashtagTools = [resultObjects v_map:^VHashtagType *(VHashtag *hashtag)
                                  {
                                      if ( [hashtag isKindOfClass:[VHashtag class]] )
                                      {
                                          return [[VHashtagType alloc] initWithHashtagText:hashtag.tag];
                                      }
                                      else
                                      {
                                          return nil;
                                      }
                                  }];
         if ( completion != nil )
         {
             completion( hashtagTools );
         }
     }
                                               failBlock:^(NSOperation *operation, NSError *error)
     {
         if ( completion != nil )
         {
             completion( nil );
         }
     }];
}

@end
