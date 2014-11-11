//
//  VTappableTextManagerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "VTappableTextManager.h"
#import "VAsyncTestHelper.h"
#import "NSObject+VMethodSwizzling.h"

/**
 Exposes private methods
 */
@interface VTappableTextManager(UnitTests)

- (void)textTapped:(UITapGestureRecognizer *)tap;
- (BOOL)findTextInTextView:(UITextView *)textView atPoint:(CGPoint)tapPoint detectionCallback:(void (^)(NSString *text))callback;

@end

@interface MockHashTagsDelegate : NSObject <VTappableTextManagerDelegate>

@property (nonatomic, strong) NSTextStorage *textStorage;
@property (nonatomic, strong) NSLayoutManager *containerLayoutManager;
@property (nonatomic, strong) NSTextContainer *textContainer;

@end

@implementation MockHashTagsDelegate

- (instancetype)initWithTextContainerSize:(CGSize)size
{
    self = [super init];
    if (self)
    {
        self.containerLayoutManager = [[NSLayoutManager alloc] init];
        self.textContainer = [[NSTextContainer alloc] initWithSize:size];
        self.textContainer.widthTracksTextView = YES;
        self.textContainer.heightTracksTextView = YES;
        [self.containerLayoutManager addTextContainer:self.textContainer];
        self.textStorage = [[NSTextStorage alloc] init];
        [self.textStorage addLayoutManager:self.containerLayoutManager];
    }
    return self;
}

@end

@interface VTappableTextManagerTests : XCTestCase
{
    VTappableTextManager *_tappableTextManager;
    MockHashTagsDelegate *_delegate;
    CGRect _frame;
    VAsyncTestHelper *_asyncHelper;
}

@end

@implementation VTappableTextManagerTests

- (void)setUp
{
    [super setUp];
    
    _asyncHelper = [[VAsyncTestHelper alloc] init];
    _frame = CGRectMake( 0, 0, 15, 320 );
    _tappableTextManager = [[VTappableTextManager alloc] init];
    _delegate = [[MockHashTagsDelegate alloc] initWithTextContainerSize:_frame.size];
}

- (void)tearDown
{
    [super tearDown];
    
    _tappableTextManager = nil;
}

- (void)runInvalidDelegateTests
{
    XCTAssertFalse( _tappableTextManager.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
    NSError *error = nil;
    XCTAssertThrows( [_tappableTextManager setDelegate:nil] );
    
    error = nil;
    XCTAssertThrows( [_tappableTextManager setDelegate:_delegate] );
    
    XCTAssertThrows( [_tappableTextManager setDelegate:_delegate] );
}

- (void)testDelegateInvalidNoTextStorage
{
    _delegate.textStorage = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManager
{
    _delegate.containerLayoutManager = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainer
{
    _delegate.textContainer = nil;
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoTextContainerInLayoutMabager
{
    [_delegate.containerLayoutManager removeTextContainerAtIndex:0];
    [self runInvalidDelegateTests];
}

- (void)testDelegateInvalidNoLayoutManagerInTextStorage
{
    [[_delegate textStorage] removeLayoutManager:_delegate.containerLayoutManager];
    [self runInvalidDelegateTests];
}

- (void)testDelegateValid
{
    XCTAssertFalse( _tappableTextManager.hasValidDelegate, @"Delegate should be invalid before it is set." );
    
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    
    XCTAssertTrue( _tappableTextManager.hasValidDelegate, @"Delegate should be valid now that it is set." );
    
    [_tappableTextManager unsetDelegate];
    XCTAssertFalse( _tappableTextManager.hasValidDelegate, @"Delegate should be invalid after it is unset." );
    
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
}

- (void)testCreateTextViewWithoutDelegate
{
    UITextView *textView = [_tappableTextManager createTappableTextViewWithFrame:_frame];
    XCTAssertNil( textView, @"Without first setting a delegate, result should be nil" );
}

- (void)testCreateTextView
{
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    
    UITextView *textView = [_tappableTextManager createTappableTextViewWithFrame:_frame];
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
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    UITextView *textView = [_tappableTextManager createTappableTextViewWithFrame:_frame];
    textView.text = @""; // Empty
    XCTAssertFalse( [_tappableTextManager findTextInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testDetectHashTagsInvalidTextField
{
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    UITextView *textView = [[UITextView alloc] init];
    textView.text = @"Hello #world";
    XCTAssertFalse( [_tappableTextManager findTextInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testDetectHashTagsInvalidNoDelegate
{
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    UITextView *textView = [_tappableTextManager createTappableTextViewWithFrame:_frame];
    textView.text = @"Hello #world";
    [_tappableTextManager unsetDelegate];
    XCTAssertFalse( [_tappableTextManager findTextInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
}

- (void)testRangesOfStrings
{
    NSString *hashTag1 = @"world1";
    NSString *hashTag2 = @"world2";
    NSString *text = [NSString stringWithFormat:@"Hello #%@ #%@", hashTag1, hashTag2];
    NSArray *strings = @[ hashTag1, hashTag2 ];
    NSArray *ranges = _tappableTextManager.tappableTextRanges = [_tappableTextManager rangesOfStrings:strings inText:text];
    XCTAssertEqual( strings.count, ranges.count );
    XCTAssertNotEqual( strings.count, (NSUInteger)0 );
    [ranges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[NSValue class]] );
    }];
}

- (void)testDetectHashTags
{
    XCTAssertNoThrow( [_tappableTextManager setDelegate:_delegate] );
    UITextView *textView = [_tappableTextManager createTappableTextViewWithFrame:_frame];
    
    textView.text = @"Hello world";
    // Should still return true without no hash tags.  Return value indicates an error, not hash tag detection
    XCTAssertTrue( [_tappableTextManager findTextInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
    
    NSString *hashTag1 = @"world1";
    NSString *hashTag2 = @"world2";
    textView.text = [NSString stringWithFormat:@"Hello #%@ #%@", hashTag1, hashTag2];
    _tappableTextManager.tappableTextRanges = [_tappableTextManager rangesOfStrings:@[ hashTag1, hashTag2 ] inText:textView.text];
    XCTAssertTrue( [_tappableTextManager findTextInTextView:textView atPoint:CGPointZero detectionCallback:nil] );
    
    __block BOOL hashTag1Detected = NO;
    __block BOOL hashTag2Detected = NO;
    
    // The following loop simulates a tap at every point in the textview's frame
    for ( NSUInteger x = CGRectGetMinX(_frame); x < CGRectGetMaxX(_frame); x++ )
    {
        for ( NSUInteger y = CGRectGetMinY(_frame); y < CGRectGetMaxY(_frame); y++ )
        {
            CGPoint point = CGPointMake( x, y );
            [_tappableTextManager findTextInTextView:textView atPoint:point detectionCallback:^(NSString *hashTag) {
                
                if ( [hashTag isEqualToString:hashTag1] )
                {
                    hashTag1Detected = YES;
                }
                else if ( [hashTag isEqualToString:hashTag2] )
                {
                    hashTag2Detected = YES;
                }
            }];
        }
    }
    
    [_asyncHelper waitForSignal:5.0f withSignalBlock:^BOOL{
        // Check that both hash tags were detected
        return hashTag1Detected && hashTag2Detected;
    }];
    
    XCTAssertTrue( hashTag1Detected );
    XCTAssertTrue( hashTag2Detected );
}

@end
