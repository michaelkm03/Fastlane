//
//  VAbstractInviteTableViewController.h
//  victorious
//
//  Created by Gary Philipp on 5/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VInviteFriendTableViewCell.h"

@interface VAbstractInviteTableViewController : UITableViewController   <VInviteFriendTableViewCellDelegate>
@property (nonatomic, strong)   NSArray*    users;

- (IBAction)refresh:(id)sender;
@end
