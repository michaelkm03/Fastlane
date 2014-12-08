//
//  VPurchaseRecordTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VPurchaseRecord.h"

static NSString * const kUnitTestFilePath = @"unit.test.filepath";

@interface VPurchaseRecord (UnitTests)

@property (nonatomic, readonly) NSString *absoluteFilepath;

@end

@interface VPurchaseRecordTests : XCTestCase

@property (nonatomic, strong) VPurchaseRecord *purchaseRecord;

@end

@implementation VPurchaseRecordTests

- (void)setUp
{
    [super setUp];
    
    self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kUnitTestFilePath];
    
    // In case you want to look and verify for yourself:
    NSLog( @"Unit test file path: %@", self.purchaseRecord.absoluteFilepath );
}

- (void)tearDown
{
    [[NSFileManager defaultManager] removeItemAtPath:self.purchaseRecord.absoluteFilepath error:nil];
}

- (void)testLoadEmpty
{
    [self.purchaseRecord loadPurchasedProductIdentifiers];
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)0 );
}

- (void)testSaveAndReload
{
    NSString *identifier = @"test.product.identifier.0";
    [self.purchaseRecord addProductIdentifier:identifier];
    XCTAssertNotNil( self.purchaseRecord.purchasedProductIdentifiers);
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)1 );
    XCTAssertEqualObjects( self.purchaseRecord.purchasedProductIdentifiers.firstObject, identifier );
    
    self.purchaseRecord = [[VPurchaseRecord alloc] initWithRelativeFilePath:kUnitTestFilePath];
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)0 );
    [self.purchaseRecord loadPurchasedProductIdentifiers];
    XCTAssertEqual( self.purchaseRecord.purchasedProductIdentifiers.count, (NSUInteger)1 );
    XCTAssertEqualObjects( self.purchaseRecord.purchasedProductIdentifiers.firstObject, identifier );
}

@end
