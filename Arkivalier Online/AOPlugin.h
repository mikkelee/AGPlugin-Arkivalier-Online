//
//  AOPlugin.h
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 11/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGPluginProtocol.h"
#import <WebKit/WebKit.h>

@class AOService1;
@class AOWebViewWindow;

@interface AOPlugin : NSObject <AGPlugin, NSWindowDelegate> {
    IBOutlet AOWebViewWindow *aoWindow;
    IBOutlet WebView *aoWebView;
    IBOutlet NSProgressIndicator *progressIndicator;
}

- (void)resetSessionID;

@property (strong) id<AGPluginMetadataTarget> metadataTarget;
@property (readonly) NSString * sessionID;
@property (strong) AOService1 * service;
@property (strong) NSMutableDictionary * status;
@property (strong) NSDictionary *tableInfo;

@property (readonly) WebView * aoWebView;

@end
