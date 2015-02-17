//
//  VInlineUserTableViewCell.h
//  victorious
//
//  Created by Lawrence Leach on 2/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VUser;

@interface VInlineUserTableViewCell : UITableViewCell
@property (nonatomic, strong)   VUser  *profile;
@property (nonatomic, strong)   VUser  *owner;
@property (nonatomic)           BOOL    showButton;
@property (nonatomic)           BOOL    showLocation;
@property (nonatomic)           BOOL    haveRelationship;

@property (nonatomic, weak)     IBOutlet UIButton *followButton;

@property (nonatomic, copy) void (^followButtonAction)(void);

- (void)disableFollowIcon:(id)sender;
- (void)flipFollowIconAction:(id)sender;

@end
