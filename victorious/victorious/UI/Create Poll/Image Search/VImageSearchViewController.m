//
//  VImageSearchViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConstants.h"
#import "VImageSearchDataSource.h"
#import "VImageSearchResult.h"
#import "VImageSearchResultCell.h"
#import "VImageSearchResultsFooterView.h"
#import "VImageSearchViewController.h"
#import "UIStoryboard+VMainStoryboard.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "victorious-Swift.h"

static NSString * const kSearchResultCellReuseIdentifier          = @"kSearchResultCellReuseIdentifier";
static NSString * const kSearchResultSectionFooterReuseIdentifier = @"kSearchResultSectionFooterReuseIdentifier";
static const CGFloat    kVerySmallScale                           =  0.001f;
static const CGFloat    kSearchResultSectionFooterHeight          = 45.0f;
static const CGFloat    kHeightRatioForRefresh                    =  0.1f;

@interface VImageSearchViewController () <UICollectionViewDelegateFlowLayout, UISearchBarDelegate, VImageSearchDataDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *noResultsLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, weak) VImageSearchResultsFooterView *refreshFooter;

@property (nonatomic, strong) VImageSearchDataSource  *dataSource;
@property (nonatomic, strong) AFImageRequestOperation *imageRequestOperation;
@property (nonatomic, strong) VDependencyManager *dependencyMananger;

@property (nonatomic) BOOL refreshing;

@end

@implementation VImageSearchViewController
{
    NSString *_searchTerm;
}

+ (instancetype)newImageSearchViewControllerWithDependencyManager:(VDependencyManager *)dependencyMananger
{
    VImageSearchViewController *imageSearchViewController = (VImageSearchViewController *)[[UIStoryboard v_mainStoryboard] instantiateViewControllerWithIdentifier:NSStringFromClass([VImageSearchViewController class])];
    imageSearchViewController.dependencyMananger = dependencyMananger;
    return imageSearchViewController;
}

- (void)dealloc
{
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[VImageSearchDataSource alloc] init];
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.contentInset = UIEdgeInsetsMake(13.0f, 5.0f, 5.0f, 5.0f);
    [self.collectionView registerClass:[VImageSearchResultCell class] forCellWithReuseIdentifier:kSearchResultCellReuseIdentifier];
    
    self.title = NSLocalizedString(@"Image Search", @"");
    NSDictionary *titleAttributes = @{ NSForegroundColorAttributeName : [UIColor whiteColor] };
    self.navigationController.navigationBar.titleTextAttributes = titleAttributes;
    
    self.searchBar.placeholder = NSLocalizedString(@"Search", @"");
    UITextField *searchTextField = (UITextField *)[self.searchBar v_findSubviews:^BOOL(UIView *__nonnull view) {
        return [view isKindOfClass:[UITextField class]];
    }].firstObject;
    searchTextField.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0f];
    searchTextField.tintColor = [self.dependencyMananger colorForKey:VDependencyManagerLinkColorKey];
    searchTextField.font = [self.dependencyMananger fontForKey:VDependencyManagerHeading4FontKey];
    if (_searchTerm)
    {
        self.searchBar.text = _searchTerm;
    }
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(71.0f, 71.0f);
    flowLayout.minimumInteritemSpacing = 5.0f;
    
    self.noResultsLabel.font = [self.dependencyMananger fontForKey:VDependencyManagerHeading4FontKey];
    self.noResultsLabel.text = NSLocalizedString(@"No results", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ( [self isReadyToSearch] )
    {
        [self performSearch];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.searchBar becomeFirstResponder];
}

- (BOOL)isReadyToSearch
{
    return self.searchTerm.length > 0 && ![self.searchTerm isEqualToString:self.dataSource.searchTerm];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Button handlers

- (IBAction)closeButtonTapped:(id)sender
{
    [self.searchBar resignFirstResponder];
    
    [self didFinishWithImageSelected:NO previewImage:nil capturedMediaURL:nil];
}

#pragma mark - 

- (void)performSearch
{
    [self.searchBar resignFirstResponder];
    self.noResultsLabel.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self.dataSource searchWithSearchTerm:self.searchBar.text
                             onCompletion:^(void)
    {
        [self.activityIndicatorView stopAnimating];
        self.noResultsLabel.hidden = [self.dataSource searchResultCount] > 0;
        self.collectionView.contentOffset = CGPointZero;
    }
                                  onError:^(NSError *error)
    {
        [self.activityIndicatorView stopAnimating];
    }];
    
    NSDictionary *params = @{ VTrackingKeySearchTerm : self.searchBar.text ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventCameraDidSearchForImage parameters:params];
}

- (NSString *)searchTerm
{
    if ([self isViewLoaded])
    {
        return self.searchBar.text;
    }
    else
    {
        return _searchTerm;
    }
}

- (void)setSearchTerm:(NSString *)searchTerm
{
    if ([self isViewLoaded])
    {
        self.searchBar.text = searchTerm;
        if (self.view.superview)
        {
            [self performSearch];
        }
    }
    else
    {
        _searchTerm = [searchTerm copy];
    }
}

- (void)didFinishWithImageSelected:(BOOL)wasImageSelected
                      previewImage:(UIImage *)previewImage
                  capturedMediaURL:(NSURL *)capturedMediaURL
{
    NSString *eventName = wasImageSelected ? VTrackingEventCameraDidSelectImageFromImageSearch : VTrackingEventCameraDidExitImageSearch;
    NSDictionary *params = nil;
    if ( [capturedMediaURL pathExtension] != nil )
    {
        params = @{ VTrackingKeyMediaType : [capturedMediaURL pathExtension] };
    }
    [[VTrackingManager sharedInstance] trackEvent:eventName parameters:params];
    
    if ( self.imageSelectionHandler != nil )
    {
        self.imageSelectionHandler( wasImageSelected, previewImage, capturedMediaURL );
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self performSearch];
    [self.searchBar resignFirstResponder];
}

#pragma mark - VImageSearchDataDelegate methods

- (UICollectionViewCell *)dataSource:(VImageSearchDataSource *)dataSource cellForSearchResult:(VImageSearchResult *)searchResult atIndexPath:(NSIndexPath *)indexPath
{
    VImageSearchResultCell *searchResultCell = (VImageSearchResultCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultCellReuseIdentifier forIndexPath:indexPath];
    [searchResultCell.imageView sd_setImageWithURL:searchResult.thumbnailURL];
    return searchResultCell;
}

- (UICollectionReusableView *)dataSource:(VImageSearchDataSource *)dataSource viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([UICollectionElementKindSectionFooter isEqualToString:kind])
    {
        self.refreshFooter = (VImageSearchResultsFooterView *)[self.collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                                      withReuseIdentifier:kSearchResultSectionFooterReuseIdentifier
                                                                                                             forIndexPath:indexPath];
        if (self.refreshing)
        {
            self.refreshFooter.refreshImageView.hidden = YES;
            [self.refreshFooter.activityIndicatorView startAnimating];
        }
        return self.refreshFooter;
    }
    else
    {
        return nil;
    }
}

#pragma mark - UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    VImageSearchResult *searchResult = [self.dataSource searchResultAtIndexPath:indexPath];
    if (![self.imageRequestOperation.request.URL isEqual:searchResult.sourceURL])
    {
        [self.imageRequestOperation cancel];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:searchResult.sourceURL];
        __typeof(self) __weak weakSelf = self;
        self.imageRequestOperation = [AFImageRequestOperation imageRequestOperationWithRequest:request
                                                                          imageProcessingBlock:nil
                                                                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                NSData *jpegData = UIImageJPEGRepresentation(image, VConstantJPEGCompressionQuality);
                NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                [jpegData writeToURL:tempFile atomically:NO];
                
                [strongSelf didFinishWithImageSelected:YES previewImage:image capturedMediaURL:tempFile];
                
                [strongSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }
                                                                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ImageDownloadFailed", @"")
                                                                    message:@""
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                                          otherButtonTitles:nil];
                [alertView show];
                [strongSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }];
        [self.imageRequestOperation start];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if ([self.dataSource searchResultCount])
    {
        return CGSizeMake(0, kSearchResultSectionFooterHeight);
    }
    else
    {
        return CGSizeZero;
    }
}

#pragma mark - UIScrollViewDelegate methods

- (CGFloat)distanceFromBottom
{
    return self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.frame) - self.collectionView.contentSize.height - self.collectionView.contentInset.bottom;
}

- (CGFloat)neededDistance
{
    return CGRectGetHeight(self.collectionView.frame) * kHeightRatioForRefresh;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat distanceFromBottom = [self distanceFromBottom];
    CGFloat neededDistance = [self neededDistance];
    
    if (distanceFromBottom <= 0)
    {
        self.refreshFooter.refreshImageView.transform = CGAffineTransformIdentity;
    }
    else
    {
        CGFloat scale = MAX(1.0f - distanceFromBottom / neededDistance, 0);
        self.refreshFooter.refreshImageView.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    CGFloat distanceFromBottom = [self distanceFromBottom];
    CGFloat neededDistance = [self neededDistance];
    
    if (distanceFromBottom >= neededDistance)
    {
        self.refreshFooter.refreshImageView.hidden = YES;
        [self.refreshFooter.activityIndicatorView startAnimating];
        self.refreshing = YES;
        self.refreshFooter.activityIndicatorView.transform = CGAffineTransformMakeScale(kVerySmallScale, kVerySmallScale);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^(void)
        {
            self.refreshFooter.activityIndicatorView.transform = CGAffineTransformIdentity;
        }
                         completion:^(BOOL finished)
        {
            [self.dataSource loadNextPageWithCompletion:^(void)
            {
                self.refreshing = NO;
                [self.refreshFooter.activityIndicatorView stopAnimating];
                self.refreshFooter.refreshImageView.hidden = NO;
            }
                                                  error:^(NSError *error)
            {
                self.refreshing = NO;
                [self.refreshFooter.activityIndicatorView stopAnimating];
                self.refreshFooter.refreshImageView.hidden = NO;
            }];
        }];
    }
}

@end
