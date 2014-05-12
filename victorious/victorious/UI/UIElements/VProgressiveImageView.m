//
//  VProgressiveImageView.m
//  victorious
//
//  Created by Gary Philipp on 5/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VProgressiveImageView.h"

#define DEGREES_TO_RADIANS(degrees) ((degrees) / (180.0 / M_PI))

static  const   CGFloat     kVLineWidth  =   3.0f;

@interface  VImageCache : NSObject

@property (nonatomic, strong) NSURL      *cacheURL;

- (void)setImageData:(NSData *)imageData forURL:(NSURL *)url;
- (UIImage *)imageForURL:(NSURL *)URL;

@end

@interface  VProgressiveImageView   ()  <NSURLSessionDataDelegate>

@property (nonatomic, strong) CAShapeLayer* backgroundLayer;
@property (nonatomic, strong) CAShapeLayer* progressLayer;

@property (nonatomic, strong) UIImageView*  containerImageView;
@property (nonatomic, strong) UIView*       progressContainer;

@property (nonatomic, strong) VImageCache*  cache;

@end

@implementation VProgressiveImageView

- (id)initWithFrame:(CGRect)frame
{
    return [[VProgressiveImageView alloc] initWithFrame:frame
                                backgroundProgressColor:[UIColor whiteColor]
                                          progressColor:[UIColor colorWithRed:240/255.f green:85/255.f blue:97/255.f alpha:1.f]];
}

- (id)initWithFrame:(CGRect)frame backgroundProgressColor:(UIColor *)backgroundProgresscolor progressColor:(UIColor *)progressColor
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.cornerRadius     = CGRectGetWidth(self.bounds) / 2.0f;
        self.layer.masksToBounds    = NO;
        self.clipsToBounds          = YES;
        _cacheEnabled               = YES;
        
        _cache = [[VImageCache alloc] init];
        
        CGPoint arcCenter           = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        CGFloat radius              = MIN(CGRectGetMidX(self.bounds)-1, CGRectGetMidY(self.bounds)-1);
        
        UIBezierPath *circlePath    = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                     radius:radius
                                                                 startAngle:-DEGREES_TO_RADIANS(90)
                                                                   endAngle:DEGREES_TO_RADIANS(360-90)
                                                                  clockwise:YES];
        
        _backgroundLayer = [CAShapeLayer layer];
        _backgroundLayer.path           = circlePath.CGPath;
        _backgroundLayer.strokeColor    = [backgroundProgresscolor CGColor];
        _backgroundLayer.fillColor      = [[UIColor clearColor] CGColor];
        _backgroundLayer.lineWidth      = kVLineWidth;
        
        
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.path         = _backgroundLayer.path;
        _progressLayer.strokeColor  = [progressColor CGColor];
        _progressLayer.fillColor    = _backgroundLayer.fillColor;
        _progressLayer.lineWidth    = _backgroundLayer.lineWidth;
        _progressLayer.strokeEnd    = 0.f;
        
        
        _progressContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _progressContainer.layer.cornerRadius   = CGRectGetWidth(self.bounds)/2.f;
        _progressContainer.layer.masksToBounds  = NO;
        _progressContainer.clipsToBounds        = YES;
        _progressContainer.backgroundColor      = [UIColor clearColor];
        
        _containerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(1, 1, frame.size.width-2, frame.size.height-2)];
        _containerImageView.image = [UIImage imageNamed:@"profileGenericUser"];
        _containerImageView.layer.cornerRadius = CGRectGetWidth(self.bounds)/2.f;
        _containerImageView.layer.masksToBounds = NO;
        _containerImageView.clipsToBounds = YES;
        _containerImageView.contentMode = UIViewContentModeScaleAspectFill;
        
        [_progressContainer.layer addSublayer:_backgroundLayer];
        [_progressContainer.layer addSublayer:_progressLayer];
        
        [self addSubview:_containerImageView];
        [self addSubview:_progressContainer];
    }

    return self;
}

- (void)setImageURL:(NSURL *)url
{
    UIImage *cachedImage = (_cacheEnabled) ? [_cache imageForURL:url] : nil;
    
    if (cachedImage)
    {
        [self updateWithImage:cachedImage animated:NO];
    }
    else
    {
        __weak  typeof(self)    weakSelf    =   self;
        NSURLSessionConfiguration*  sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        sessionConfig.allowsCellularAccess = YES;
        
        NSURLSession*               session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                            delegate:self
                                                                       delegateQueue:nil];
        NSURLSessionDataTask*       task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                            {
                                                if (data.length > 0)
                                                {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        [weakSelf updateWithImage:[UIImage imageWithData:data] animated:YES];
                                                        if (_cacheEnabled)
                                                            [_cache setImageData:data forURL:url];
                                                   });
                                                }
                                            }];
        [task resume];
    }
 }

- (void)updateWithImage:(UIImage *)image animated:(BOOL)animated
{
    CGFloat duration    = (animated) ? 0.3 : 0.f;
    CGFloat delay       = (animated) ? 0.1 : 0.f;

    _containerImageView.transform   = CGAffineTransformMakeScale(0, 0);
    _containerImageView.alpha       = 0.f;
    _containerImageView.image       = image;
    
    [UIView animateWithDuration:duration
                     animations:^{
                         _progressContainer.transform    = CGAffineTransformMakeScale(1.1, 1.1);
                         _progressContainer.alpha        = 0.f;
                         [UIView animateWithDuration:duration
                                               delay:delay
                                             options:UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              _containerImageView.transform   = CGAffineTransformIdentity;
                                              _containerImageView.alpha       = 1.f;
                                          } completion:nil];
                     } completion:^(BOOL finished) {
                         _progressLayer.strokeColor = [[UIColor whiteColor] CGColor];
                         [UIView animateWithDuration:duration
                                          animations:^{
                                              _progressContainer.transform    = CGAffineTransformIdentity;
                                              _progressContainer.alpha        = 1.f;
                                          }];
                     }];
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat progress = (CGFloat)totalBytesSent/(CGFloat)totalBytesExpectedToSend;
        _progressLayer.strokeEnd        = progress;
        _backgroundLayer.strokeStart    = progress;
    });
}

@end

@implementation VImageCache

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSURL*      rootCacheURL    =   [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];

        _cacheURL      = [rootCacheURL URLByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[_cacheURL path]])
            [[NSFileManager defaultManager] createDirectoryAtURL:_cacheURL withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    return self;
}

- (void)setImageData:(NSData *)imageData forURL:(NSURL *)url
{
    [imageData writeToURL:[_cacheURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%u.%@", url.hash, url.pathExtension]] atomically:YES];
}

- (UIImage *)imageForURL:(NSURL *)url
{
    NSURL*  path = [_cacheURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%u.%@", url.hash, url.pathExtension]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path.path])
        return [UIImage imageWithData:[NSData dataWithContentsOfURL:path]];

    return nil;
}

@end
