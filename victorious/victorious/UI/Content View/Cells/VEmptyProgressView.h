//
//  VEmptyProgressView.h
//  victorious
//
//  Created by Michael Sena on 9/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

/**
 *  When there are no realtime comments use this cell.
 */
@interface VEmptyProgressView : VBaseCollectionViewCell

/**
 *  The current elapsed progress to display.
 */
@property (nonatomic, assign) CGFloat progress;

@end
