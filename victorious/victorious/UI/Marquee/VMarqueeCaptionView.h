//
//  VMarqueeCaptionView.h
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VStreamItem, VDependencyManager;

/**
    A view that displays a properly formatted headline from a stream item whenever possible,
        falls back to displaying the name of a stream item. This class also manages the appearance
        of the label, headline divider lines, and constraints around these views.
 */
@interface VMarqueeCaptionView : UIView

/**
    Populates the caption view based on the provided stream item and api path.
 
    @param marqueeItem The stream item whose headline or name should be displayed as appropriate.
    @param apiPath The api path of the stream containing the stream item, used to determine which headline should be displayed.
 */
- (void)setupWithMarqueeItem:(VStreamItem *)marqueeItem fromStreamWithApiPath:(NSString *)apiPath;

@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependency manager used to style this caption view.
@property (nonatomic, weak) IBOutlet UILabel *captionLabel; ///< The label that will display the appropriate field from the provided stream item.
@property (nonatomic, readonly) VStreamItem *marqueeItem; ///< The stream item whose headline or name is being displayed.
@property (nonatomic, readonly) BOOL hasHeadline; ///< Indicates whether or not this view is displaying the headline field from the provided stream item.

@end
