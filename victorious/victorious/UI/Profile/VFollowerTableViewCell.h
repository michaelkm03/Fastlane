//
//  VFollowerTableViewCell.h
//  victorious
//
//  Created by Gary Philipp on 5/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@class VUser;

@interface VFollowerTableViewCell : UITableViewCell

@property (nonatomic, strong)   VUser  *profile;
@property (nonatomic, strong)   VUser  *owner;
@property (nonatomic)           BOOL    showButton;
@property (nonatomic)           BOOL    haveRelationship;

@property (nonatomic, weak)     IBOutlet UIButton *followButton;

@property (nonatomic, copy) void (^followButtonAction)(void);

- (void)disableFollowIcon:(id)sender;
- (void)flipFollowIconAction:(id)sender;

@end
