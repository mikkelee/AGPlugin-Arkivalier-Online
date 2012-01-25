//
//  AOWebViewWindow.h
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 19/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AOPlugin;

@interface AOWebViewWindow : NSWindow {}

@property (strong) AOPlugin * plugin;

@end
