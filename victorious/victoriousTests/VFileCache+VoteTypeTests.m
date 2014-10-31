//
//  VFileCache+VVoteTypeTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/14/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFileCache.h"
#import "VFileCache+VVoteType.h"
#import "VAsyncTestHelper.h"
#import "VFileSystemTestHelpers.h"
#import "VDummyModels.h"
#import "VVoteType+Fetcher.h"
#import "NSObject+VMethodSwizzling.h"

@interface VFileCache ( UnitTest)

- (NSString *)savePathForVoteTypeSprite:(VVoteType *)voteType atFrameIndex:(NSUInteger)index;
- (NSString *)savePathForImage:(NSString *)imageName forVote:(VVoteType *)voteType;
- (NSArray *)savePathsForVoteTypeSprites:(VVoteType *)voteType;
- (BOOL)validateVoteType:(VVoteType *)voteType;
- (NSData *)synchronousDataFromUrl:(NSString *)urlString;

@end

static NSString * const kTestImageUrl = @"https://www.google.com/images/srpr/logo11w.png";

@interface VoteTypeTests : XCTestCase

@property (nonatomic, strong) VFileCache *fileCache;
@property (nonatomic, strong) VAsyncTestHelper *asyncHelper;
@property (nonatomic, strong) NSArray *voteTypes;
@property (nonatomic, strong) VVoteType *voteType;
@property (nonatomic, assign) IMP originalImplementation;

@end

@implementation VoteTypeTests

- (void)setUp
{
    [super setUp];
    
    self.asyncHelper = [[VAsyncTestHelper alloc] init];
    self.fileCache = [[VFileCache alloc] init];
    
    self.voteTypes = [VDummyModels createVoteTypes:10];
    [self.voteTypes enumerateObjectsUsingBlock:^(VVoteType *voteType, NSUInteger idx, BOOL *stop)
    {
        voteType.name = @"vote_type_test_name";
        voteType.iconImage = kTestImageUrl;
        voteType.imageFormat = @"http://media-dev-public.s3-website-us-west-1.amazonaws.com/_static/ballistics/7/images/firework_XXXXX.png";
        voteType.imageCount = @( 10 );
        
        NSString *directoryPath = [NSString stringWithFormat:VVoteTypeFilepathFormat, voteType.name];
        [VFileSystemTestHelpers deleteCachesDirectory:directoryPath];
    }];
    
    
    self.originalImplementation = [VFileCache v_swizzleMethod:@selector(synchronousDataFromUrl:) withBlock:(NSData *)^(NSString *url)
                                   {
                                       NSBundle *bundle = [NSBundle bundleForClass:[self class]];
                                       NSURL *previewImageFileURL = [bundle URLForResource:@"sampleImage" withExtension:@"png"];
                                       UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:previewImageFileURL]];
                                       return UIImagePNGRepresentation( image );
                                   }];
    
    self.voteType = self.voteTypes.firstObject;
}

- (void)tearDown
{
    [super tearDown];
    
    self.voteTypes = nil;
    self.fileCache = nil;
    
    [VFileCache v_restoreOriginalImplementation:self.originalImplementation forMethod:@selector(synchronousDataFromUrl:)];
}

- (void)testSavePathConstructionIcon
{
    NSString *savePath;
    NSString *expectedSavePath;
    
    savePath = [self.fileCache savePathForImage:VVoteTypeIconName forVote:self.voteType];
    expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:VVoteTypeIconName];
    XCTAssertEqualObjects( expectedSavePath, savePath );
}

- (void)testSpriteSavePathConstruction
{
    for ( NSUInteger i = 0; i < 20; i++ )
    {
        NSString *spriteSavePath = [self.fileCache savePathForVoteTypeSprite:self.voteType atFrameIndex:i];
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedSavePath, spriteSavePath );
    }
}

- (void)testSpriteSavePathConstructionArray
{
    NSArray *savePaths = [self.fileCache savePathsForVoteTypeSprites:self.voteType];
    
    [savePaths enumerateObjectsUsingBlock:^(NSString *savePath, NSUInteger i, BOOL *stop) {
        NSString *spriteName = [NSString stringWithFormat:VVoteTypeSpriteNameFormat, i];
        NSString *expectedSavePath = [[NSString stringWithFormat:VVoteTypeFilepathFormat, self.voteType.name] stringByAppendingPathComponent:spriteName];
        XCTAssertEqualObjects( expectedSavePath, savePath );
    }];
}

- (void)testCacheVoteTypeImages
{
    // Make sure files don't exist first
    XCTAssertFalse( [self.fileCache isImageCached:VVoteTypeIconName forVoteType:self.voteType] );
    XCTAssertFalse( [self.fileCache areSpriteImagesCachedForVoteType:self.voteType] );
    
    // Load files
    [self.fileCache cacheImagesForVoteTypes:self.voteTypes];
    
    [self.asyncHelper waitForSignal:10.0f withSignalBlock:^BOOL{
        
        NSString *iconPath = [self.fileCache savePathForImage:VVoteTypeIconName forVote:self.voteType];
        BOOL iconExists = [VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:iconPath];
        
        // Make sure the sprite image swere saved
        __block BOOL spritesExist = YES;
        NSArray *images = self.voteType.images;
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *spritePath = [self.fileCache savePathForVoteTypeSprite:self.voteType atFrameIndex:idx];
            if ( ![VFileSystemTestHelpers fileExistsInCachesDirectoryWithLocalPath:spritePath] )
            {
                spritesExist = NO;
                *stop = YES;
            }
        }];
        
        return iconExists && spritesExist;
    }];
    
    XCTAssert( [self.fileCache isImageCached:VVoteTypeIconName forVoteType:self.voteType] );
    XCTAssert( [self.fileCache areSpriteImagesCachedForVoteType:self.voteType] );
    
    UIImage *image = [self.fileCache getImageWithName:VVoteTypeIconName forVoteType:self.voteType];
    XCTAssertNotNil( image );
    XCTAssertNotNil( [[UIImageView alloc] initWithImage:image] );
    
    NSArray *spriteImages = [self.fileCache getSpriteImagesForVoteType:self.voteType];
    XCTAssertEqual( spriteImages.count, self.voteType.images.count );
    [spriteImages enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        XCTAssert( [obj isKindOfClass:[UIImage class]] );
        UIImage *image = (UIImage *)obj;
        XCTAssertNotNil( image );
        XCTAssertNotNil( [[UIImageView alloc] initWithImage:image] );
    }];
}

- (void)testCacheImagesInvalid
{
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:@[]] );
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:nil] );
    XCTAssertNoThrow( [self.fileCache cacheImagesForVoteTypes:(@[ [NSNull null], [NSNull null] ]) ] );
}

@end
