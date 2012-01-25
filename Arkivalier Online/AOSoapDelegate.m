//
//  AOSoapDelegate.m
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 12/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "AOSoapDelegate.h"

@implementation AOSoapDelegate

#pragma mark Protocol methods

- (id)initWithTarget:(id<AGPluginImageLoadTarget>)target plugin:(AOPlugin *)plugin key:(NSString *)key
{
    self = [super init];
    if (self) {
        [self setTarget:target];
        [self setPlugin:plugin];
        [self setKey:key];
    }
    
    return self;
}

- (void)go
{
    [[[self plugin] service] getImage2:self sessionId:[[self plugin] sessionID] name:[self key]];
}

#pragma mark Results

- (void) onload: (id) value
{
    NSLog(@"loaded.");
    NSData *imgData = [value valueForKey:@"imageData"];
	[[self target] imageDataDidLoad:imgData];
    [[[self plugin] status] removeObjectForKey:[self key]];
    NSURL *laviewerURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), 
                                            @".LAViewer/data", 
                                            [[self key] stringByReplacingOccurrencesOfString:@"/" withString:@"."]]];
    NSLog(@"Saving %lu bytes to %@", [imgData length], laviewerURL);
    [imgData writeToURL:laviewerURL atomically:YES];
}

- (void) onerror: (NSError*) error
{
    //TODO
    NSLog(@"error: %@", error);
    [[self plugin] resetSessionID];
}

- (void) onfault: (SoapFault*) fault
{
    //TODO
    NSLog(@"fault: %@", fault);
    [[self plugin] resetSessionID];
}

#pragma mark Misc

- (BOOL)isEqual:(id)other
{
    if ([[other class] isEqual:[self class]]) {
        return [[self target] isEqual:[other target]];
    } else {
        return NO;
    }
}

#pragma mark Properties

@synthesize target;
@synthesize plugin;
@synthesize key;

@end
