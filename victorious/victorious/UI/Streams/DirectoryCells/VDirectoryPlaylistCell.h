//
//  VDirectoryPlaylistCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VStreamItem;

@interface VDirectoryPlaylistCell : VBaseCollectionViewCell

/**
 *  The VStream used to populate fields on the cell.
 */
@property (nonatomic, strong) VStreamItem *stream;

@end
