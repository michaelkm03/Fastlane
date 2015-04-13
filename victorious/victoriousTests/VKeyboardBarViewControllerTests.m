//
//  VKeyboardBarViewControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VKeyboardBarViewController.h"

@interface VMockKeyboardBarViewController : VKeyboardBarViewController <UITextViewDelegate>

@property (nonatomic, assign) NSInteger mockCharacterLimit;

@end

@implementation VMockKeyboardBarViewController

- (NSInteger)characterLimit
{
    return self.mockCharacterLimit;
}

@end

@interface VKeyboardBarViewControllerTests : XCTestCase

@property (nonatomic, strong) VMockKeyboardBarViewController *keyboardBarViewController;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL didCancelKeyboardBarWasCalled;

@end

@implementation VKeyboardBarViewControllerTests

- (void)setUp
{
    [super setUp];
    
    self.keyboardBarViewController = [[VMockKeyboardBarViewController alloc] init];
    self.keyboardBarViewController.mockCharacterLimit = 20;
    self.didCancelKeyboardBarWasCalled = NO;
    self.textView = [[UITextView alloc] init];
    self.keyboardBarViewController.delegate = (id<VKeyboardBarDelegate>)self;
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAddWithinRange
{
    self.keyboardBarViewController.mockCharacterLimit = 20;
    self.textView.text = @"0123456789";
    NSString *replacementText = @"abcdefghik";
    NSRange range = NSMakeRange( self.textView.text.length, 0 );
    BOOL output = [self.keyboardBarViewController textView:self.textView shouldChangeTextInRange:range replacementText:replacementText];
    XCTAssertFalse( self.didCancelKeyboardBarWasCalled );
    XCTAssertTrue( output );
}

- (void)testInsertWithinRange
{
    self.keyboardBarViewController.mockCharacterLimit = 20;
    self.textView.text = @"01289";
    NSString *replacementText = @"abcde";
    NSRange range = NSMakeRange( 3, 0 );
    BOOL output = [self.keyboardBarViewController textView:self.textView shouldChangeTextInRange:range replacementText:replacementText];
    XCTAssertFalse( self.didCancelKeyboardBarWasCalled );
    XCTAssertTrue( output );
}

- (void)testRejectNewLineWithReturnKeys
{
    self.keyboardBarViewController.mockCharacterLimit = 20;
    for ( NSNumber *num in @[ @(UIReturnKeyGo), @(UIReturnKeyDone), @(UIReturnKeySend)] )
    {
        self.didCancelKeyboardBarWasCalled = YES;
        self.textView.returnKeyType = (UIReturnKeyType)num.integerValue;
        self.textView.text = @"01289";
        NSString *replacementText = @"\n";
        NSRange range = NSMakeRange( self.textView.text.length, 0 );
        BOOL output = [self.keyboardBarViewController textView:self.textView shouldChangeTextInRange:range replacementText:replacementText];
        XCTAssertTrue( self.didCancelKeyboardBarWasCalled );
        XCTAssertFalse( output );
    }
}

- (void)testAcceptNewLine
{
    self.keyboardBarViewController.mockCharacterLimit = 20;
    for ( NSNumber *num in @[ @(UIReturnKeyDefault),
                              @(UIReturnKeyGoogle),
                              @(UIReturnKeyJoin),
                              @(UIReturnKeyNext),
                              @(UIReturnKeyRoute),
                              @(UIReturnKeySearch),
                              @(UIReturnKeyYahoo),
                              @(UIReturnKeyEmergencyCall) ])
    {
        self.didCancelKeyboardBarWasCalled = NO;
        self.textView.returnKeyType = (UIReturnKeyType)num.integerValue;
        self.textView.text = @"01289";
        NSString *replacementText = @"\n";
        NSRange range = NSMakeRange( self.textView.text.length, 0 );
        BOOL output = [self.keyboardBarViewController textView:self.textView shouldChangeTextInRange:range replacementText:replacementText];
        XCTAssertFalse( self.didCancelKeyboardBarWasCalled );
        XCTAssert( output );
    }
}

- (void)testExceedsRange
{
    const NSInteger limit = 20;
    self.keyboardBarViewController.mockCharacterLimit = limit;
    NSString *initialText = @"012345678912345";
    self.textView.text = initialText;
    NSString *replacementText = @"abcdefghik";
    NSRange range = NSMakeRange( self.textView.text.length, 0 );
    BOOL output = [self.keyboardBarViewController textView:self.textView shouldChangeTextInRange:range replacementText:replacementText];
    XCTAssertFalse( self.didCancelKeyboardBarWasCalled );
    XCTAssertFalse( output );
    NSString *combinedText = [initialText stringByAppendingString:replacementText];
    XCTAssertEqualObjects( self.textView.text, [combinedText substringWithRange:NSMakeRange(0, limit)] );
}

#pragma mark - VKeyboardBarDelegate

- (void)didCancelKeyboardBar:(VKeyboardBarViewController *)keyboardBar
{
    self.didCancelKeyboardBarWasCalled = YES;
}

@end
