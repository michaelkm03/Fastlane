//
//  VCCameraFocusView
//

#import <UIKit/UIKit.h>
#import "VCCamera.h"

@interface VCCameraFocusView : UIView

@property (weak, nonatomic) VCCamera *camera;
@property (strong, nonatomic) UIImage *outsideFocusTargetImage;
@property (strong, nonatomic) UIImage *insideFocusTargetImage;
@property (assign, nonatomic) CGSize focusTargetSize;

- (void)showFocusAnimation;
- (void)hideFocusAnimation;

@end
