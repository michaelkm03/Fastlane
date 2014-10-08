//
//  VHistogramCell.h
//  victorious
//
//  Created by Michael Sena on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

#import "VHistogramView.h"

@interface VHistogramCell : VBaseCollectionViewCell

@property (nonatomic, weak, readonly) VHistogramView *histogramView;

@end
