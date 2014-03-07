//
//  SCCameraFocusView.h
//  SCAudioVideoRecorder
//

#import <UIKit/UIKit.h>
#import "SCCamera.h"

@interface SCCameraFocusView : UIView

@property (weak, nonatomic) SCCamera *camera;
@property (strong, nonatomic) UIImage *outsideFocusTargetImage;
@property (strong, nonatomic) UIImage *insideFocusTargetImage;
@property (assign, nonatomic) CGSize focusTargetSize;

- (void)showFocusAnimation;
- (void)hideFocusAnimation;

@end
