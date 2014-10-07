//
//  VStreamCollectionViewController.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

#import "VStreamCollectionViewDataSource.h"
#import "VStreamCollectionCell.h"

#import "VStream.h"


static NSString * const kStreamCollectionStoryboardId = @"kStreamCollection";

@interface VStreamCollectionViewController ()

@property (strong, nonatomic) VStreamCollectionViewDataSource *directoryDataSource;

@end

@implementation VStreamCollectionViewController

+ (instancetype)streamViewControllerForStream:(VStream *)stream
{
    UIViewController *currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
    VStreamCollectionViewController *streamDirectory = (VStreamCollectionViewController *)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kStreamCollectionStoryboardId];
    
    streamDirectory.stream = stream;
    
    return streamDirectory;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UINib *nib = [UINib nibWithNibName:VStreamCollectionCellName bundle:nil];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:VStreamCollectionCellName];
    
    [self refresh:self.refreshControl];
}

#pragma mark - VStreamCollectionDataDelegate

- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForStreamItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)indexPath
{
    VStreamItem *item = [self.stream.streamItems objectAtIndex:indexPath.row];
    VStreamCollectionCell *cell;
    
    cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:VStreamCollectionCellName forIndexPath:indexPath];
    cell.sequence = (VSequence *)item;
    
    return cell;
}

@end
