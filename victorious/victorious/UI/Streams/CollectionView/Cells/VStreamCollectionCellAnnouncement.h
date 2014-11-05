//
//  VStreamCollectionCellAnnouncement.h
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

@interface VStreamCollectionCellAnnouncement : VStreamCollectionCell

- (void)loadAnnouncementUrl:(NSString *)urlString forceReload:(BOOL)fshouldForceReload;

@end
