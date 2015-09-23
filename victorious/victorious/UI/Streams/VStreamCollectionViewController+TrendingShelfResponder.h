//
//  VStreamCollectionViewController+TrendingShelfResponder.h
//  victorious
//
//  Created by Sharif Ahmed on 8/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamCollectionViewController.h"

@protocol VShelfStreamItemSelectionResponder, VTrendingUserShelfResponder, VTrendingHashtagShelfResponder;

@interface VStreamCollectionViewController (TrendingShelfResponder) <VShelfStreamItemSelectionResponder, VTrendingUserShelfResponder, VTrendingHashtagShelfResponder>

@end
