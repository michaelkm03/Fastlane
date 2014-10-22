//
//  VHistogramCell.h
//  victorious
//
//  Created by Michael Sena on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

#import "VHistogramBarView.h"

@interface VHistogramCell : VBaseCollectionViewCell

@property (nonatomic, weak, readonly) VHistogramBarView *histogramView;

@end
