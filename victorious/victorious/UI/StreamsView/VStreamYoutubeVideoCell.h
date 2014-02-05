//
//  VStreamYoutubeVideoCell.h
//  victorious
//
//  Created by Will Long on 2/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamViewCell.h"

@class VSequence;

static NSString *kStreamYoutubeVideoCellIdentifier = @"VStreamYoutubeVideoCell";

@interface VStreamYoutubeVideoCell : VStreamViewCell

@property (nonatomic, weak) IBOutlet UIWebView* webView;

@end
