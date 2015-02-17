//
//  VPhotoFilterCollectionViewDataSource.m
//  victorious
//
//  Created by Josh Hinman on 7/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPhotoFilter.h"
#import "VPhotoFilterCollectionViewCell.h"
#import "VPhotoFilterCollectionViewDataSource.h"
#import "VPhotoFilterSerialization.h"

NSString * const kPhotoFilterCellIdentifier = @"kPhotoFilterCellIdentifier";
const NSInteger kVOriginalImageSectionIndex = 0;
const NSInteger kVPhotoFiltersSectionIndex  = 1;

@interface VPhotoFilterCollectionViewDataSource ()

@property (nonatomic, strong) NSArray          *filters;
@property (nonatomic, strong) NSCache          *filteredImages;
@property (nonatomic, strong) dispatch_queue_t  filterQueue;
@property (nonatomic, strong) CIContext        *coreImageContext;

@end

@implementation VPhotoFilterCollectionViewDataSource

- (id)init
{
    self = [super init];
    if (self)
    {
        _filteredImages = [[NSCache alloc] init];
        _filterQueue = dispatch_queue_create("VPhotoFilterCollectionViewDataSource", DISPATCH_QUEUE_SERIAL);
        _coreImageContext = [CIContext contextWithOptions:@{}];
    }
    return self;
}

- (NSArray *)filters
{
    if (!_filters)
    {
        _filters = [self loadFilterData];
    }
    return _filters;
}

- (NSArray *)loadFilterData
{
    NSURL *filters = [[NSBundle bundleForClass:[self class]] URLForResource:@"filters" withExtension:@"xml"];
    if (filters)
    {
        return [VPhotoFilterSerialization filtersFromPlistFile:filters];
    }
    else
    {
        return nil;
    }
}

- (void)setSourceImage:(UIImage *)sourceImage
{
    dispatch_async(self.filterQueue, ^(void)
    {
        _sourceImage = sourceImage;
        [self.filteredImages removeAllObjects];
    });
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == kVOriginalImageSectionIndex)
    {
        return 1;
    }
    else if (section == kVPhotoFiltersSectionIndex)
    {
        return self.filters.count;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kVOriginalImageSectionIndex)
    {
        VPhotoFilterCollectionViewCell *cell = (VPhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterCellIdentifier forIndexPath:indexPath];
        cell.label.text = [NSLocalizedString(@"Normal", @"") uppercaseStringWithLocale:[NSLocale currentLocale]];
        cell.imageView.image = self.sourceImage;
        return cell;
    }
    else if (indexPath.section == kVPhotoFiltersSectionIndex)
    {
        VPhotoFilter *filter = [self filterAtIndexPath:indexPath];
        VPhotoFilterCollectionViewCell *cell = (VPhotoFilterCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoFilterCellIdentifier forIndexPath:indexPath];
        cell.label.text = [filter.name uppercaseStringWithLocale:[NSLocale currentLocale]];
        UIImage *image = [self.filteredImages objectForKey:indexPath];
        if (!image)
        {
            VPhotoFilter *filterCopy = [filter copy];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
            {
                UIImage *filteredImage = [filterCopy imageByFilteringImage:self.sourceImage withCIContext:self.coreImageContext];
                if (filteredImage)
                {
                    dispatch_async(dispatch_get_main_queue(), ^(void)
                    {
                        [self.filteredImages setObject:filteredImage forKey:indexPath];
                        if ([[collectionView indexPathForCell:cell] isEqual:indexPath])
                        {
                            cell.imageView.image = filteredImage;
                        }
                    });
                }
            });
        }
        else
        {
            cell.imageView.image = image;
        }
        return cell;
    }
    else
    {
        return nil;
    }
}

- (VPhotoFilter *)filterAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section == kVPhotoFiltersSectionIndex, @"only section %ld has filters", (long)kVPhotoFiltersSectionIndex);
    return self.filters[indexPath.item];
}

@end
