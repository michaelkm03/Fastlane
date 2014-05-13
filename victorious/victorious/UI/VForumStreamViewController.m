//
//  VForumStreamViewController.m
//  victorious
//
//  Created by Gary Philipp on 1/16/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VForumStreamViewController.h"
#import "VConstants.h"

//Cells
#import "VStreamViewCell.h"
#import "VStreamPollCell.h"

//Data Models
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"


@interface VForumStreamViewController ()
@property (nonatomic, strong)   NSFetchedResultsController*     fetchedResultsController;
@end

@implementation VForumStreamViewController

+ (VForumStreamViewController *)sharedInstance
{
    static  VForumStreamViewController*   sharedInstance;
    static  dispatch_once_t         onceToken;
    dispatch_once(&onceToken, ^{
        UIViewController*   currentViewController = [[UIApplication sharedApplication] delegate].window.rootViewController;
        sharedInstance = (VForumStreamViewController*)[currentViewController.storyboard instantiateViewControllerWithIdentifier: kForumStreamStoryboardID];
    });
    
    return sharedInstance;
}

- (NSArray*)sequenceCategories
{
    return @[kVOwnerForumCategory, kVUGCForumCategory];
}


- (VStreamViewCell*)tableView:(UITableView *)tableView streamViewCellForIndex:(NSIndexPath*)indexPath
{
    VSequence* sequence = (VSequence*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (([sequence isForum] || [sequence isVideo])
        && [[[sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
        return [tableView dequeueReusableCellWithIdentifier:kStreamYoutubeCellIdentifier
                                               forIndexPath:indexPath];
    
    else if ([sequence isForum] || [sequence isVideo])
        return [tableView dequeueReusableCellWithIdentifier:kStreamVideoCellIdentifier
                                               forIndexPath:indexPath];
    
    else
        return [tableView dequeueReusableCellWithIdentifier:kStreamViewCellIdentifier
                                               forIndexPath:indexPath];
}

- (void)registerCells
{
    //TODO:replace with Forum Image Cell xib name.
    [self.tableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamViewCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamViewCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamViewCellIdentifier];
    
    //TODO:replace with Forum Youtube Video Cell xib name
    [self.tableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamYoutubeCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamYoutubeCellIdentifier];
    
    //TODO:replace with Forum Video Cell xib name
    [self.tableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:nil]
         forCellReuseIdentifier:kStreamVideoCellIdentifier];
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:kStreamVideoCellIdentifier bundle:nil] forCellReuseIdentifier:kStreamVideoCellIdentifier];
}

@end
