//
//  VTrimmerViewController.m
//  victorious
//
//  Created by Michael Sena on 12/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrimmerViewController.h"

#import "VThumbnailCell.h"
#import "VTrimControl.h"

@interface VTrimmerViewController () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *thumbnailCollecitonView;

@property (nonatomic, strong) VTrimControl *trimControl;

@end

@implementation VTrimmerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(CGRectGetHeight(self.view.frame), CGRectGetHeight(self.view.frame));
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.thumbnailCollecitonView = [[UICollectionView alloc] initWithFrame:self.view.bounds
                                                      collectionViewLayout:layout];
    [self.thumbnailCollecitonView registerNib:[VThumbnailCell nibForCell]
                   forCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]];
    self.thumbnailCollecitonView.dataSource = self;
    self.thumbnailCollecitonView.delegate = self;
    self.thumbnailCollecitonView.backgroundColor = [UIColor clearColor];

    [self.view addSubview:self.thumbnailCollecitonView];
    self.thumbnailCollecitonView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewMap = @{@"collectionView": self.thumbnailCollecitonView};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[collectionView]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-48-[collectionView]-30-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    self.trimControl = [[VTrimControl alloc] initWithFrame:CGRectMake(0, 0, 100, CGRectGetHeight(self.view.frame))];
    self.trimControl.translatesAutoresizingMaskIntoConstraints = NO;
    self.trimControl.startTime = CMTimeMake(0, 24);
    self.trimControl.maxDuration = CMTimeMake(30, 1);
    [self.trimControl addTarget:self
                         action:@selector(trimSelectionChanged:)
               forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.trimControl];
    viewMap = @{@"trimControl": self.trimControl};
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[trimControl]|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[trimControl]-30-|"
                                                                      options:kNilOptions
                                                                      metrics:nil
                                                                        views:viewMap]];
}

#pragma mark - Target/Action

- (void)trimSelectionChanged:(VTrimControl *)trimControl
{
    VLog(@"%@, %@", @(trimControl.selectionRange.start.value),@(trimControl.selectionRange.duration.value) );
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return 15;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VThumbnailCell *thumnailCell = [collectionView dequeueReusableCellWithReuseIdentifier:[VThumbnailCell suggestedReuseIdentifier]
                                                                             forIndexPath:indexPath];
    thumnailCell.thumbnail = [UIImage imageNamed:@"bike"];
    return thumnailCell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetHeight(collectionView.frame), CGRectGetHeight(collectionView.frame));
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

@end
