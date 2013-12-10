//
//  VStreamsTableViewController.h
//  victoriOS
//
//  Created by goWorld on 12/2/13.
//  Copyright (c) 2013 Will Long. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VStreamsTableViewController : UITableViewController  <NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>


- (IBAction)filterAll:(id)sender;
- (IBAction)filterVideoForums:(id)sender;
- (IBAction)filterPolls:(id)sender;
- (IBAction)filterImages:(id)sender;
- (IBAction)filterVideos:(id)sender;


@end
