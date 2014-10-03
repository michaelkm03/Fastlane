//
//  VTappableHashTagsTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "VTappableHashTags.h"
#import "VAsyncTestHelper.h"

@interface VTappableHashTags(UnitTests)

- (BOOL)detectHashTagsInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *hashTag))callback;

@end

@interface MockHashTagsDelegate : NSObject <VTappableHashTagsDelegate>

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *layoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation MockHashTagsDelegate

- (instancetype)initWithTextContainerSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        self.layoutManager = [[NSLayoutManager alloc] init];
        self.textContainer = [[NSTextContainer alloc] initWithSize:size];
        self.textContainer.widthTracksTextView = YES;
        self.textContainer.heightTracksTextView = YES;
        [self.layoutManager addTextContainer:self.textContainer];
        self.textStorage = [[NSTextStorage alloc] init];
        [self.textStorage addLayoutManager:self.layoutManager];
    }
    return self;
}

@end

@interface VTappableHashTagsTests : XCTestCase
{
    VTappableHashTags *_tappableHashTags;
    MockHashTagsDelegate *_delegate;
    CGRect _frame;
    VAsyncTestHelper *_asyncHelper;
}

@end

@implementation VTappableHashTagsTests

- (void)setUp
{
    [super setUp];
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _frame = CGRectMake( 0, 0, 20, 200 );
    _tappableHashTags = [[VTappableHashTags alloc] init];
    _delegate = [[MockHashTagsDelegate alloc] initWithTextContainerSize:_frame.size];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)runInvalidDelegateTests
{
    XCTAssertFalse( _tappableHashTags.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
    NSError *error = nil;
    XCTAssertFalse( [_tappableHashTags setDelegate:nil error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    
    error = nil;
    XCTAssertFalse( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNotNil( error );
    XCTAssertNotNil( error.domain );
    
    XCTAssertFalse( [_tappableHashTags setDelegate:_delegate error:nil] );
}

- (void)testDelegateInvalidNoTextStorage
{
    _delegate.textStorage = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManager
{
    _delegate.layoutManager = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainer
{
    _delegate.textContainer = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainerInLayoutMabager
{
    [[_delegate layoutManager] removeTextContainerAtIndex:0];
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManagerInTextStorage
{
    [[_delegate textStorage] removeLayoutManager:_delegate.layoutManager];
    [self runInvalidDelegateTests];
}

- (void)testDelegateValid
{
    XCTAssertFalse( _tappableHashTags.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
    NSError *error = nil;
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNil( error );
    
    XCTAssertTrue( _tappableHashTags.hasValidDelegate, @"Delegate should be valid now that it is set." );
    
    [_tappableHashTags unsetDelegate];
    XCTAssertFalse( _tappableHashTags.hasValidDelegate, @"Delegate should be invalid after it is unset." );
    
    error = nil;
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:&error] );
    XCTAssertNil( error );
    
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
}

- (void)testCreateTextViewWithoutDelegate
{
    UITextView *textView = [_tappableHashTags createTappableTextViewWithFrame:_frame];
    XCTAssertNil( textView, @"Without first setting a delegate, result should be nil" );
}

- (void)testCreateTextView
{
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
    
    UITextView *textView = [_tappableHashTags createTappableTextViewWithFrame:_frame];
    XCTAssertNotNil( textView );
    
    XCTAssertTrue( CGRectEqualToRect( textView.frame, _frame ) );
    XCTAssertEqual( textView.backgroundColor, [UIColor clearColor] );
    XCTAssertEqual( textView.textColor, [UIColor whiteColor] );
    XCTAssertEqual( textView.translatesAutoresizingMaskIntoConstraints, NO );
    XCTAssertEqual( textView.editable, NO );
    XCTAssertEqual( textView.selectable, NO );
    XCTAssertEqual( textView.scrollEnabled, NO );
    XCTAssertTrue( UIEdgeInsetsEqualToEdgeInsets( textView.textContainerInset, UIEdgeInsetsZero ) );
    XCTAssertTrue( textView.gestureRecognizers.count >= 1 );
}

- (void)testDetectHashTagsInvalidText
{
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
    UITextView *textView = [_tappableHashTags createTappableTextViewWithFrame:_frame];
    textView.text = @""; // Empty
    XCTAssertFalse( [_tappableHashTags detectHashTagsInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testDetectHashTagsInvalidTextField
{
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
    UITextView *textView = [[UITextView alloc] init];
    textView.text = @"Hello #world";
    XCTAssertFalse( [_tappableHashTags detectHashTagsInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testDetectHashTagsInvalidNoDelegate
{
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
    UITextView *textView = [_tappableHashTags createTappableTextViewWithFrame:_frame];
    textView.text = @"Hello #world";
    [_tappableHashTags unsetDelegate];
    XCTAssertFalse( [_tappableHashTags detectHashTagsInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testDetectHashTags
{
    XCTAssertTrue( [_tappableHashTags setDelegate:_delegate error:nil] );
    UITextView *textView = [_tappableHashTags createTappableTextViewWithFrame:_frame];
    
    textView.text = @"Hello world";
    // Should still return true without no hash tags.  Return value indicates an error, not hash tag detection
    XCTAssertTrue( [_tappableHashTags detectHashTagsInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
    
    NSString* hashTag1 = @"#world1";
    NSString* hashTag2 = @"#world1";
    textView.text = [NSString stringWithFormat:@"Hello %@ %@", hashTag1, hashTag2];
    XCTAssertTrue( [_tappableHashTags detectHashTagsInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
    
    __block NSMutableArray* detectedHashTags = [[NSMutableArray alloc] init];
    
    // The following loop simulates taps at every pixel on the x-axis across the midY point of the y-axis
    for ( NSUInteger x = CGRectGetMinX(_frame); x < CGRectGetMaxX(_frame); x++ )
    {
        CGPoint point = CGPointMake( x, CGRectGetMidY( _frame ) );
        [_tappableHashTags detectHashTagsInTextView:textView atPoint:point detectionCallback:^(NSString *hashTag) {
            [detectedHashTags addObject:hashTag];
        }];
    }
}

@end
