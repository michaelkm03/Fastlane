//
//  VStreamContentSegue.h
//  victorious
//
//  Created by Will Long on 3/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStreamViewCell;

@interface VStreamContentSegue : UIStoryboardSegue

@property (strong, nonatomic) VStreamViewCell* selectedCell;

@end
