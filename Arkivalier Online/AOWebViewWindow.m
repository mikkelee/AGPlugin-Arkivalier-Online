//
//  AOWebViewWindow.m
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 19/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "AOWebViewWindow.h"
#import "AOPlugin.h"

@implementation AOWebViewWindow

- (void)sendEvent:(NSEvent *)theEvent
{
    [super sendEvent:theEvent];
    
    if ([theEvent type] == NSLeftMouseDown) {
        NSPoint point = [theEvent locationInWindow];
        WebView *aoWebView = [[self plugin] aoWebView];
        NSDictionary *dict = [aoWebView elementAtPoint:[aoWebView convertPoint:point fromView:[self contentView]]];
        
        DOMNode *node = [dict objectForKey:@"WebElementDOMNode"];
        
        if ([node isKindOfClass:[DOMHTMLElement class]]) {
            NSLog(@"node: %@ %@", node, [(DOMHTMLElement *)node idName]);
            
            if([[(DOMHTMLElement *)node idName] hasPrefix:@"dgBoeger_"] || [[node localName] isEqualToString:@"td"]) {
                DOMNode *row = [node parentNode];
                while (![row isKindOfClass:[DOMHTMLTableRowElement class]]) {
                    //NSLog(@"parent: %@ %@", node, [(DOMHTMLElement *)node idName]);
                    row = [row parentNode];
                }
                DOMNodeList *cells = [row childNodes];
                DOMNodeList *header = [[[row parentNode] firstChild] childNodes];
                
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithCapacity:5];
                for (int i = 0; i < [cells length]; i++) {
                    DOMNode *child = [cells item:i];
                    if ([child respondsToSelector:@selector(textContent)]) {
                        NSString *trimmedKey = [[[header item:i] textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString *trimmedValue = [[child textContent] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        
                        if (![trimmedKey isEqualToString:@""]) {
                            [info setObject:trimmedValue forKey:trimmedKey];
                        }
                    }
                }
                
                NSLog(@"info: %@", info);
                [[self plugin] setTableInfo:info];
            }
        } else {
            //NSLog(@"node: %@", node);
        }
    }
}

@synthesize plugin;

@end
