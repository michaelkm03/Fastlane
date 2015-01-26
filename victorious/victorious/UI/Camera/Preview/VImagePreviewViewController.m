//
//  VImagePreviewViewController.m
//  victorious
//
//  Created by Gary Philipp on 2/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+Cropping.h"
#import "VImagePreviewViewController.h"
#import "VPhotoFilter.h"
#import "VPhotoFilterCollectionViewCell.h"
#import "VPhotoFilterCollectionViewDataSource.h"
#import "VThemeManager.h"
#import "VConstants.h"

@interface VImagePreviewViewController () <UICollectionViewDelegate>

@property (nonatomic, weak)     UIImageView                          *previewImageView;
@property (nonatomic, weak)     UICollectionView                     *filterCollectionView;
@property (nonatomic, strong)   VPhotoFilterCollectionViewDataSource *filterDataSource;
@property (nonatomic, strong)   NSURL                                *filteredMediaURL;
@property (nonatomic)           BOOL                                  mediaURLneedsUpdating; ///< YES if the mediaURL does not point to a current version of the image
@property (nonatomic, readonly) CIContext                            *coreImageContext;

@end

@implementation VImagePreviewViewController
{
    UIImage   *_originalImage;
    UIImage   *_filteredImage;
    CIContext *_coreImageContext;
}

- (instancetype)initWithMediaURL:(NSURL *)mediaURL
{
    self = [super initWithMediaURL:mediaURL];
    if (self)
    {
        _originalImage = _filteredImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.mediaURL]]; // self.mediaURL *should *be a local file URL.
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.doneButton.hidden = YES;
    
    UIImageView *previewImageView = [[UIImageView alloc] initWithImage:[self previewImage]];
    previewImageView.translatesAutoresizingMaskIntoConstraints = NO;
    previewImageView.clipsToBounds = YES;
    previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.previewImageSuperview addSubview:previewImageView];
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[previewImageView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(previewImageView)]];
    [self.previewImageSuperview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[previewImageView]|"
                                                                                       options:0
                                                                                       metrics:nil
                                                                                         views:NSDictionaryOfVariableBindings(previewImageView)]];
    self.previewImageView = previewImageView;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(71.0f, 107.0f);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    UICollectionView *filterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    filterCollectionView.translatesAutoresizingMaskIntoConstraints = NO;
    filterCollectionView.backgroundColor = [UIColor whiteColor];
    [filterCollectionView registerClass:[VPhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:kPhotoFilterCellIdentifier];
    [self.view addSubview:filterCollectionView];
    
    UIView *bottomButtonSuperview = self.bottomButtonSuperview;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[filterCollectionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(filterCollectionView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[filterCollectionView(==107)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(filterCollectionView, bottomButtonSuperview)]];
    self.filterCollectionView = filterCollectionView;
    self.filterDataSource = [[VPhotoFilterCollectionViewDataSource alloc] init];
    self.filterDataSource.sourceImage = [self.previewImage squareImageScaledToSize:63.0f];
    self.filterCollectionView.dataSource = self.filterDataSource;
    self.filterCollectionView.delegate = self;
    [self.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:kVOriginalImageSectionIndex]
                                            animated:NO
                                      scrollPosition:UICollectionViewScrollPositionLeft];
}

- (UIImage *)previewImage
{
    return _filteredImage;
}

- (CIContext *)coreImageContext
{
    if (!_coreImageContext)
    {
        _coreImageContext = [CIContext contextWithOptions:@{}];
    }
    return _coreImageContext;
}

- (void)willComplete
{
    if (self.mediaURLneedsUpdating)
    {
        NSURL *originalMediaURL = self.mediaURL;
        NSData *filteredImageData = UIImageJPEGRepresentation(_filteredImage, VConstantJPEGCompressionQuality);
        NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
        NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
        if ([filteredImageData writeToURL:tempFile atomically:YES])
        {
            self.mediaURL = tempFile;
            [[NSFileManager defaultManager] removeItemAtURL:originalMediaURL error:nil];
            self.mediaURLneedsUpdating = NO;
        }
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [super mediaPreviewTapped:nil];
    self.mediaURLneedsUpdating = YES;
    if (indexPath.section == kVOriginalImageSectionIndex)
    {
        self.previewImageView.image = _filteredImage = _originalImage;
    }
    else if (indexPath.section == kVPhotoFiltersSectionIndex)
    {
        dispatch_async(dispatch_get_main_queue(), ^(void)
        {
            VPhotoFilter *filter = [self.filterDataSource filterAtIndexPath:indexPath];
            self.previewImageView.image = _filteredImage = [filter imageByFilteringImage:_originalImage withCIContext:self.coreImageContext];
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [super mediaPreviewTapped:nil];
}

@end
