//
//  VStreamsTableViewController.h
//  victoriOS
//
//  Created by goWorld on 12/2/13.
//  Copyright (c) 2013 Victorious Inc. All rights reserved.
//

#import "VAbstractStreamViewController.h"
#import "VCreateSequenceDelegate.h"

@interface VStreamsTableViewController : VAbstractStreamViewController
<VCreateSequenceDelegate>

+ (instancetype)sharedStreamsTableViewController;

- (IBAction)addButtonAction:(id)sender;

@end
