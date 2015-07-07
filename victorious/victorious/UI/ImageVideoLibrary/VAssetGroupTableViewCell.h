//
//  VAssetGroupTableViewCell.h
//  victorious
//
//  Created by Michael Sena on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VAssetGroupTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *groupImageView;
@property (strong, nonatomic) IBOutlet UILabel *groupTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *groupSubtitleLabel;

@end
