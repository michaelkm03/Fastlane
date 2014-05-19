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
#import "VImageSearchViewController.h"

static NSString * const kSearchResultCellReuseIdentifier = @"kSearchResultCellReuseIdentifier";

@interface VImageSearchViewController ()

@property (nonatomic, weak) IBOutlet UITextField        *searchField;
@property (nonatomic, weak) IBOutlet UICollectionView   *collectionView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *hrHeightConstraint;

@property (nonatomic, strong) VImageSearchDataSource  *dataSource;
@property (nonatomic, strong) AFImageRequestOperation *imageRequestOperation;

@end

@implementation VImageSearchViewController

+ (instancetype)newImageSearchViewController
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VImageSearchViewController *flickrPicker = (VImageSearchViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([VImageSearchViewController class])];
    return flickrPicker;
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
    [self.dataSource searchWithSearchTerm:self.searchField.text
                             onCompletion:nil
                                  onError:^(NSError *error)
    {
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

@end
