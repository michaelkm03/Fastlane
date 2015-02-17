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

@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel     *profileName;

@property (nonatomic, strong) VUser  *profile;

@end
