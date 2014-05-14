//
//  VFollowerTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

@interface VFollowerTableViewCell : UITableViewCell

@property (nonatomic, copy) VUser*  profile;
@property (nonatomic)       BOOL    showButton;

@end
