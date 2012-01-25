//
//  AOSoapDelegate.h
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 12/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AOService1.h"
#import "AGPluginProtocol.h"
#import "AOPlugin.h"

@interface AOSoapDelegate : NSObject <SoapDelegate> {}

#pragma mark Protocol methods

- (id)initWithTarget:(id<AGPluginImageLoadTarget>)target plugin:(AOPlugin *)plugin key:(NSString *)key;
- (void)go;

#pragma mark Results

- (void) onload: (id) value;
- (void) onerror: (NSError*) error;
- (void) onfault: (SoapFault*) fault;

#pragma mark Misc

- (BOOL)isEqual:(id)other;

#pragma mark Properties

@property (strong) id<AGPluginImageLoadTarget> target;
@property (strong) AOPlugin * plugin;
@property (strong) NSString * key;

@end
