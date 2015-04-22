//
//  VTemplateDecoratorTests.m
//  victorious
//
//  Created by Patrick Lynch on 4/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VTemplateDecorator.h"

@interface VTemplateDecorator()

- (NSDictionary *)dictionaryFromJSONFile:(NSString *)filename;

@end

@interface VTemplateDecoratorTests : XCTestCase

@end

@implementation VTemplateDecoratorTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testReplaceInDictionary
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"subkey1" : @"subvalue1",
                                                             @"subkey2" : @"subvalue2" }
                                             },
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [templateDecorator dictionaryFromJSONFile:@"component"];
    
    [templateDecorator replaceComponentForKeyPath:@"key2/subkey0/subkey1" withComponentInFileNamed:@"component"];
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey1" ] isKindOfClass:[NSDictionary class]] );
    XCTAssertEqual( ((NSDictionary *)output[ @"key2" ][ @"subkey0" ][ @"subkey1" ]).allKeys.count, component.allKeys.count );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey1" ][ @"subkey3" ], component[ @"subkey3" ] );
}

- (void)testAddInDictionary
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"subkey1" : @"subvalue1",
                                                             @"subkey2" : @"subvalue2" }
                                             },
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [templateDecorator dictionaryFromJSONFile:@"component"];
    
    [templateDecorator replaceComponentForKeyPath:@"key2/subkey0/subkey5" withComponentInFileNamed:@"component"];
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey5" ] isKindOfClass:[NSDictionary class]] );
    XCTAssertEqual( ((NSDictionary *)output[ @"key2" ][ @"subkey0" ][ @"subkey5" ]).allKeys.count, component.allKeys.count );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey5" ][ @"subkey3" ], component[ @"subkey3" ] );
}

- (void)testArray
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @[@"subvalue1", @"subvalue2" ],
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [templateDecorator dictionaryFromJSONFile:@"component"];
    
    [templateDecorator replaceComponentForKeyPath:@"key2/1" withComponentInFileNamed:@"component"];
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ] isKindOfClass:[NSArray class]] );
    XCTAssertEqual( ((NSArray *)output[ @"key2" ]).count, ((NSArray *)template[ @"key2" ]).count );
    XCTAssertEqualObjects( output[ @"key2" ][1][ @"subkey3" ], component[ @"subkey3" ] );
}

@end
