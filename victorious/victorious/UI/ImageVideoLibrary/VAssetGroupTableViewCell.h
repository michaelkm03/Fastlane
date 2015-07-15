//
//  VAssetGroupTableViewCell.h
//  victorious
//
//  Created by Michael Sena on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

/**
 *  Represents an asset collection in a tableView. Assign a representative 
 *  asset to the asset property.
 */
@interface VAssetGroupTableViewCell : UITableViewCell

/**
 *  An asset to use to represent the asset collection.
 */
@property (strong, nonatomic) PHAsset *asset;

/**
 *  The title label for the cell.
 */
@property (strong, nonatomic) IBOutlet UILabel *groupTitleLabel;

/**
 *  A subtitle label for the cell. Use this to inform the user of the number of
 *  assets in the collection.
 */
@property (strong, nonatomic) IBOutlet UILabel *groupSubtitleLabel;

@end
