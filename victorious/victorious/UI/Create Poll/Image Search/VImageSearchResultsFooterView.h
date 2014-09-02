//
//  VImageSearchResultsFooterView.h
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Displays at the bottom of the image search results.
 */
@interface VImageSearchResultsFooterView : UICollectionReusableView

@property (nonatomic, weak) IBOutlet UIImageView             *refreshImageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end
