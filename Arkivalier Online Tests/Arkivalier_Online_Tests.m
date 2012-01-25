//
//  Arkivalier_Online_Tests.m
//  Arkivalier Online Tests
//
//  Created by Mikkel Eide Eriksen on 13/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "AOPlugin.h"
#import "AGPluginProtocol.h"

@interface Arkivalier_Online_Tests : SenTestCase { //<AGPluginImageLoadTarget, AGPluginMetadataTarget> {
    AOPlugin* plugin;
}

@end

@implementation Arkivalier_Online_Tests

- (void)setUp
{
    [super setUp];
    
    NSLog(@"Setting up AOPlugin");
    
    plugin = [[AOPlugin alloc] init];
}

- (void)tearDown
{
    plugin = nil;
    
    [super tearDown];
}

//- (void)testAOPlugin
//{
//    [plugin loadImageForKey:@"data/SkifteMatr/M04753/A00274/M4753_0228.Jpg" target:self];
//}
//
//- (void)imageDidLoad:(NSImage *)image
//{
//    STAssertNotNil(image, @"image shouldn't be nil!");
//}
//
//- (void)testObtainMetadata
//{
//    [plugin getNewMetadataForTarget:self];
//}
//
//- (void)metadataDidLoad:(NSDictionary *)metadata
//{
//    NSLog(@"metadataDidLoad: %@", metadata);
//    STAssertNotNil(metadata, @"metadata shouldn't be nil!");
//}


@end
