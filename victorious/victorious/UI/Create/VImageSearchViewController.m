//
//  VImageSearchViewController.m
//  victorious
//
//  Created by Josh Hinman on 4/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+ImageCreation.h"
#import "VConstants.h"
#import "VImageSearchDataSource.h"
#import "VImageSearchResult.h"
#import "VImageSearchResultCell.h"
#import "VImageSearchResultsFooterView.h"
#import "VImageSearchViewController.h"
#import "VThemeManager.h"

static NSString * const kSearchResultCellReuseIdentifier          = @"kSearchResultCellReuseIdentifier";
static NSString * const kSearchResultSectionFooterReuseIdentifier = @"kSearchResultSectionFooterReuseIdentifier";
static const CGFloat    kSearchResultSectionFooterHeight          = 45.0f;
static const CGFloat    kHeightRatioForRefresh                    =  0.1f;

@interface VImageSearchViewController () <UICollectionViewDelegateFlowLayout, UITextFieldDelegate, VImageSearchDataDelegate>

@property (nonatomic, weak) IBOutlet UIView                  *headerView;
@property (nonatomic, weak) IBOutlet UITextField             *searchField;
@property (nonatomic, weak) IBOutlet UIImageView             *searchIconImageView;
@property (nonatomic, weak) IBOutlet UICollectionView        *collectionView;
@property (nonatomic, weak) IBOutlet UILabel                 *noResultsLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint      *hrHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint      *vrWidthConstraint;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (nonatomic, weak) VImageSearchResultsFooterView *refreshFooter;

@property (nonatomic, strong) VImageSearchDataSource  *dataSource;
@property (nonatomic, strong) AFImageRequestOperation *imageRequestOperation;

@property (nonatomic) BOOL refreshing;

@end

@implementation VImageSearchViewController

+ (instancetype)newImageSearchViewController
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VImageSearchViewController *imageSearchViewController = (VImageSearchViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([VImageSearchViewController class])];
    return imageSearchViewController;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = [[VImageSearchDataSource alloc] init];
    self.dataSource.delegate = self;
    self.dataSource.collectionView = self.collectionView;
    self.collectionView.dataSource = self.dataSource;
    self.collectionView.contentInset = UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 5.0f);
    [self.collectionView registerClass:[VImageSearchResultCell class] forCellWithReuseIdentifier:kSearchResultCellReuseIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = CGSizeMake(71.0f, 71.0f);
    flowLayout.minimumInteritemSpacing = 5.0f;
    
    self.hrHeightConstraint.constant = 0.5f;
    self.vrWidthConstraint.constant = 0.5f;
    
    self.searchField.placeholder = NSLocalizedString(@"Search for an image", @"");
    self.searchField.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.searchIconImageView.image = [self.searchIconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.noResultsLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
    self.noResultsLabel.text = NSLocalizedString(@"No results", @"");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Button handlers

- (IBAction)closeButtonTapped:(id)sender
{
    if (self.completionBlock)
    {
        self.completionBlock(NO, nil, nil);
    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.noResultsLabel.hidden = YES;
    [self.activityIndicatorView startAnimating];
    [self.dataSource searchWithSearchTerm:self.searchField.text
                             onCompletion:^(void)
    {
        [self.activityIndicatorView stopAnimating];
        self.noResultsLabel.hidden = [self.dataSource searchResultCount] > 0;
        self.collectionView.contentOffset = CGPointZero;
    }
                                  onError:^(NSError *error)
    {
        [self.activityIndicatorView stopAnimating];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"SearchFailed", @"")
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
                                              otherButtonTitles:nil];
        [alert show];
    }];
    [self.searchField resignFirstResponder];
    return YES;
}

#pragma mark - VImageSearchDataDelegate methods

- (UICollectionViewCell *)dataSource:(VImageSearchDataSource *)dataSource cellForSearchResult:(VImageSearchResult *)searchResult atIndexPath:(NSIndexPath *)indexPath
{
    VImageSearchResultCell *searchResultCell = (VImageSearchResultCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kSearchResultCellReuseIdentifier forIndexPath:indexPath];
    [searchResultCell.imageView setImageWithURL:searchResult.thumbnailURL];
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
            __typeof(self) strongSelf = weakSelf;
            if (strongSelf)
            {
                if (strongSelf.completionBlock)
                {
                    NSData *jpegData = UIImageJPEGRepresentation(image, VConstantJPEGCompressionQuality);
                    NSURL *tempDirectory = [NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES];
                    NSURL *tempFile = [[tempDirectory URLByAppendingPathComponent:[[NSUUID UUID] UUIDString]] URLByAppendingPathExtension:VConstantMediaExtensionJPG];
                    [jpegData writeToURL:tempFile atomically:NO];
                    strongSelf.completionBlock(YES, image, tempFile);
                }
                [strongSelf.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            }
        }
                                                                                       failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
        {
            __typeof(self) strongSelf = weakSelf;
            if (strongSelf)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ImageDownloadFailed", @"")
                                                                    message:@""
                                                                   delegate:nil
                                                          cancelButtonTitle:NSLocalizedString(@"OKButton", @"")
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
    CGFloat distance = self.collectionView.contentOffset.y + CGRectGetHeight(self.collectionView.frame) - self.collectionView.contentSize.height - self.collectionView.contentInset.bottom;
    NSLog(@"%f", distance);
    return distance;
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
    }
}

@end
