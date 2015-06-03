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

- (void)testSetValue
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"subkey1" : @"subvalue1",
                                                             @"subkey2" : @"subvalue2" }
                                             },
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSString *newStringValue = @"templateValue";
    NSNumber *newNumberValue = @5.04f;
    
    BOOL didSucceed = [templateDecorator setTemplateValue:newStringValue forKeyPath:@"key2/subkey0/subkey1"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    didSucceed = [templateDecorator setTemplateValue:newNumberValue forKeyPath:@"key2/subkey0/subkey2"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey1" ] isKindOfClass:[NSString class]] );
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey2" ] isKindOfClass:[NSNumber class]] );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey1" ], newStringValue );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey2" ], newNumberValue );
}

- (void)testSetInTemplate
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"subkey1" : @"subvalue1",
                                                             @"subkey2" : @"subvalue2" }
                                             },
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [VTemplateDecorator dictionaryFromJSONFile:@"component"];
    
    BOOL didSucceed = [templateDecorator setComponentWithFilename:@"component" forKeyPath:@"key2/subkey0/subkey1"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey1" ] isKindOfClass:[NSDictionary class]] );
    XCTAssertEqual( ((NSDictionary *)output[ @"key2" ][ @"subkey0" ][ @"subkey1" ]).allKeys.count, component.allKeys.count );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey1" ][ @"subkey3" ], component[ @"subkey3" ] );
}

- (void)testModifyAddedComponent
{
    NSDictionary *template = @{ @"key0" : @{ @"key1" : @[ @{ @"key2" : @{ @"key3" : @"value1" } } ] } };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = @{ @"componenyKey0" : @"componenyValue0",
                                 @"componenyKey1" : @"componenyValue1",
                                 @"componenyKey2" : @"componenyValue2" };
    
    BOOL didSucceed = [templateDecorator setTemplateValue:component forKeyPath:@"key0/key1/0/key2/key3"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSString *templateValue = @"templateValue";
    didSucceed = [templateDecorator setTemplateValue:templateValue forKeyPath:@"key0/key1/0/key2/key3/componentKey0"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssertEqualObjects( output[ @"key0" ][ @"key1" ][ 0 ][ @"key2" ][ @"key3" ][ @"componentKey0" ], templateValue );
}

- (void)testAddInTemplate
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"subkey1" : @"subvalue1",
                                                             @"subkey2" : @"subvalue2" }
                                             },
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [VTemplateDecorator dictionaryFromJSONFile:@"component"];
    
    BOOL didSucceed = [templateDecorator setComponentWithFilename:@"component" forKeyPath:@"key2/subkey0/subkey5"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ][ @"subkey0" ][ @"subkey5" ] isKindOfClass:[NSDictionary class]] );
    XCTAssertEqual( ((NSDictionary *)output[ @"key2" ][ @"subkey0" ][ @"subkey5" ]).allKeys.count, component.allKeys.count );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"subkey5" ][ @"subkey3" ], component[ @"subkey3" ] );
}

- (void)testArrayHierarchyIteration
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @[@"subvalue1", @"subvalue2" ],
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSDictionary *component = [VTemplateDecorator dictionaryFromJSONFile:@"component"];
    
    BOOL didSucceed = [templateDecorator setComponentWithFilename:@"component" forKeyPath:@"key2/1"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssert( [output[ @"key2" ] isKindOfClass:[NSArray class]] );
    XCTAssertEqual( ((NSArray *)output[ @"key2" ]).count, ((NSArray *)template[ @"key2" ]).count );
    XCTAssertEqualObjects( output[ @"key2" ][1][ @"subkey3" ], component[ @"subkey3" ] );
}


- (void)testReadValue
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @[@"subvalue1", @"subvalue2" ],
                                @"key3" : @"value3" };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    BOOL didSucceed = [templateDecorator setComponentWithFilename:@"component" forKeyPath:@"key2/1"];
    XCTAssert( didSucceed, @"Failed to set component value" );
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssertEqualObjects( output[ @"key2" ], [templateDecorator templateValueForKeyPath:@"key2"] );
    XCTAssertEqualObjects( output[ @"key2" ][1], [templateDecorator templateValueForKeyPath:@"key2/1"] );
    XCTAssertEqualObjects( output[ @"key2" ][1][ @"subkey3" ], [templateDecorator templateValueForKeyPath:@"key2/1/subkey3"] );
    
    XCTAssertNil( [templateDecorator templateValueForKeyPath:@"key2/2/subkey3"] ); // Undefined index
    XCTAssertNil( [templateDecorator templateValueForKeyPath:@"key2/-1/subkey3"] ); // Undefined index
    XCTAssertNil( [templateDecorator templateValueForKeyPath:@"UNDEFINED_KEY/1/subkey3"] );
    XCTAssertNil( [templateDecorator templateValueForKeyPath:@"key2/1/UNDEFINED_KEY"] );
}

- (void)testReplaceAllOccurrences
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"key1" : @"subvalue1",
                                                             @"key2" : @"subvalue2" } },
                                @"key3" : @[ @{ @"key1" : @"subarrayvalue1" } ] };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSString *newStringValue = @"templateValue";
    
    XCTAssertThrows(  [templateDecorator setValue:nil forAllOccurencesOfKey:@"key1"] );
    
    [templateDecorator setValue:newStringValue forAllOccurencesOfKey:@"key1"];
    
    NSDictionary *output = templateDecorator.decoratedTemplate;
    
    XCTAssertEqualObjects( output[ @"key1" ], newStringValue );
    XCTAssertEqualObjects( output[ @"key2" ][ @"subkey0" ][ @"key1" ], newStringValue );
    XCTAssertEqualObjects( output[ @"key3" ][ 0 ][ @"key1" ], newStringValue );
}

- (void)testKeyPaths
{
    NSDictionary *template = @{ @"key1" : @"value1",
                                @"key2" : @{ @"subkey0" : @{ @"key4" : @"subvalue1",
                                                             @"key5" : @{ @"key4" : @"subvalue1",
                                                                          @"key5" : @"subvalue2" } } },
                                @"key3" : @[ @{ @"key6" : @"subarrayvalue1" } ],
                                @"key3" : @[ @{ @"key6" : @"subarrayvalue2" } ],
                                @"key7" : @{ @"key8" : @{ @"key6" : @"subvalue1" } } };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSArray *keyPaths;
    
    keyPaths = [templateDecorator keyPathsForKey:@"key1"];
    XCTAssertEqual( keyPaths.count, 1u );
    XCTAssertEqualObjects( keyPaths[0], @"key1" );
    
    keyPaths = [templateDecorator keyPathsForKey:@"subkey0"];
    XCTAssertEqual( keyPaths.count, 1u );
    XCTAssertEqualObjects( keyPaths[0], @"key2/subkey0" );
    
    keyPaths = [templateDecorator keyPathsForKey:@"key5"];
    XCTAssertEqual( keyPaths.count, 2u );
    XCTAssert( [keyPaths containsObject:@"key2/subkey0/key5"] );
    XCTAssert( [keyPaths containsObject:@"key2/subkey0/key5/key5"] );
    
    keyPaths = [templateDecorator keyPathsForKey:@"key6"];
    XCTAssertEqual( keyPaths.count, 2u );
    XCTAssert( [keyPaths containsObject:@"key3/0/key6"] );
    XCTAssert( [keyPaths containsObject:@"key7/key8/key6"] );
    
    keyPaths = [templateDecorator keyPathsForKey:@"keyXXX"];
    XCTAssertEqual( keyPaths.count, 0u );
    
    XCTAssertThrows( [templateDecorator keyPathsForKey:nil] );
}

- (void)testValueReplacement
{
    NSDictionary *template = @{ @"key1" : @"value9",
                                @"key2" : @{ @"subkey0" : @{ @"key4" : @"subvalue0",
                                                             @"key5" : @{ @"key4" : @"subvalue1",
                                                                          @"key5" : @"subvalue2" } } },
                                @"key3" : @[ @{ @"key6" : @"subarrayvalue1" } ],
                                @"key4" : @[ @{ @"key6" : @"subvalue3" } ] };
    
    VTemplateDecorator *templateDecorator = [[VTemplateDecorator alloc] initWithTemplateDictionary:template];
    
    NSString *replacementString = @"__REPLACEMENT__";
    NSInteger replacementCount;
    
    replacementCount = [templateDecorator replaceOccurencesOfString:@"value9" withString:replacementString];
    XCTAssertEqual( replacementCount, 1 );
    XCTAssertEqualObjects( templateDecorator.decoratedTemplate[ @"key1" ], replacementString );
    
    replacementCount = [templateDecorator replaceOccurencesOfString:@"subvalue" withString:replacementString];
    XCTAssertEqual( replacementCount, 4 );
    
    NSString *expected = [NSString stringWithFormat:@"%@0", replacementString];
    XCTAssertEqualObjects( templateDecorator.decoratedTemplate[ @"key2" ][ @"subkey0" ][ @"key4" ], expected );
    expected = [NSString stringWithFormat:@"%@1", replacementString];
    XCTAssertEqualObjects( templateDecorator.decoratedTemplate[ @"key2" ][ @"subkey0" ][ @"key5" ][ @"key4" ], expected );
    expected = [NSString stringWithFormat:@"%@2", replacementString];
    XCTAssertEqualObjects( templateDecorator.decoratedTemplate[ @"key2" ][ @"subkey0" ][ @"key5" ][ @"key5" ], expected );
    expected = [NSString stringWithFormat:@"%@3", replacementString];
    XCTAssertEqualObjects( templateDecorator.decoratedTemplate[ @"key4" ][ 0 ][ @"key6" ], expected );
}

@end
