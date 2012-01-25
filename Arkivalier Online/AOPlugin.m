//
//  AOPlugin.m
//  Arkivalier Online
//
//  Created by Mikkel Eide Eriksen on 11/01/12.
//  Copyright (c) 2012 Mikkel Eide Eriksen. All rights reserved.
//

#import "AOPlugin.h"
#import "AOService1.h"
#import "AOSoapDelegate.h"
#import "NSData+Base64.h"
#import "AOWebViewWindow.h"

#define AOLocalizedString(key, comment) NSLocalizedStringFromTableInBundle(key, nil, [NSBundle bundleForClass:[self class]], comment)

#define AOPluginName @"Arkivalier Online"

@interface AOPlugin ()

- (void)prepareXML:(NSXMLDocument *)xml withTags:(NSDictionary *)info;

@end

@implementation AOPlugin {
    NSString *__sessionID;
    NSWindowController *windowController;
}

#pragma mark Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setService:[[AOService1 alloc] init]];
        //[[self service] setLogging:YES];
        [self setStatus:[NSMutableDictionary dictionaryWithCapacity:2]];
    }
    
    return self;
}

#pragma mark User interface


#pragma mark AGPlugin protocol methods

+ (NSString *)pluginName
{
    return AOPluginName;
}

- (BOOL)getNewMetadataForTarget:(id<AGPluginMetadataTarget>)target
{
    [self setMetadataTarget:target];
    
    NSInteger result = [[NSAlert alertWithMessageText:AOPluginName
                                        defaultButton:AOLocalizedString(@"open file", @"Open file...") 
                                      alternateButton:AOLocalizedString(@"go to website", @"Go to website...") 
                                          otherButton:AOLocalizedString(@"cancel", @"Cancel") 
                            informativeTextWithFormat:AOLocalizedString(@"website or download", @"Obtain a fresh source from the website, or open one already downloaded?")] runModal];
    
    if (result == NSAlertOtherReturn) {
        return NO;    
    } else if (result == NSAlertDefaultReturn) {
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        [openPanel setMessage:AOLocalizedString(@"select file", @"Please select one or more ViewImage file(s) from Arkivalier Online")];
        [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"jnlp"]];
        [openPanel setAllowsMultipleSelection:YES];
        if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
            //TODO ask user for tags...?
            for (NSURL *url in [openPanel URLs]) {
                [self prepareXML:[[NSXMLDocument alloc] initWithContentsOfURL:url options:NSXMLDocumentTidyXML error:nil] withTags:[NSDictionary dictionaryWithObject:[url lastPathComponent] forKey:@"filename"]];
            }
            return YES;
        } else {
            return NO;    
        }
    } else if (result == NSAlertAlternateReturn) {
        windowController = [[NSWindowController alloc] initWithWindowNibName:@"AOWebViewWindow" owner:self];
        [windowController showWindow:nil];
        [[windowController window] makeKeyAndOrderFront:self];
        [aoWindow setPlugin:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidStart:) name:WebViewProgressStartedNotification object:aoWebView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidUpdate:) name:WebViewProgressEstimateChangedNotification object:aoWebView];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webViewDidFinish:) name:WebViewProgressFinishedNotification object:aoWebView];
        [aoWebView setMainFrameURL:@"http://www.sa.dk/ao/"]; //TODO get url from plist?
        //[aoWebView setMainFrameURL:@"http://www.sa.dk/ao/andre/SkifteMatr.aspx"];
        return YES;
    }
    
    NSLog(@"WTF result was %ld", result);
    return NO;    
}

- (BOOL)loadImageForKey:(NSString *)key target:(id<AGPluginImageLoadTarget>)target
{
    if ([[[self status] allKeys] count] > 0) { //TODO make preference...
        return NO;
    }
    
    // check if the file is in ~/.LAViewer/data/
    NSURL *laviewerURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@/%@", NSHomeDirectory(), 
                                          @".LAViewer/data", 
                                          [key stringByReplacingOccurrencesOfString:@"/" withString:@"."]]];
    
    //if it is, just hand that off, otherwise send off a SOAP request
    if ([laviewerURL checkResourceIsReachableAndReturnError:nil]) {
        //NSLog(@"theURL: %@ exists, loading local copy", laviewerURL);
        NSData *imgData = [[NSData alloc] initWithContentsOfURL:laviewerURL];
        [target imageDataDidLoad:imgData];
    } else {
        NSLog(@"theURL: %@ does not exist, firing off SOAP request", laviewerURL);
        AOSoapDelegate* delegate = [[AOSoapDelegate alloc] initWithTarget:target plugin:self key:key];
        [[self status] setObject:delegate forKey:key];
        [delegate go];
    }
    
    return YES;
}

- (BOOL)imageIsLoadingForKey:(NSString *)key
{
    if ([[self status] objectForKey:key] != nil) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark Internal XML handling

- (void)prepareXML:(NSXMLDocument *)xml withTags:(NSDictionary *)tags
{
    NSMutableDictionary *metadata = [NSMutableDictionary dictionaryWithCapacity:3];
    
    NSString *title = [[NSString alloc] initWithData:[NSData dataWithBase64EncodedString:[[[[xml rootElement] nodesForXPath:@"//property[@name='titel']/@value" error:nil] objectAtIndex:0] stringValue]] encoding:NSUTF8StringEncoding];
    
    [metadata setObject:title forKey:AGMetadataNameKey];

    if (tags) {
        [metadata setObject:tags forKey:AGMetadataTagsKey];
    }
    
    NSString *remoteBasePath = [[[[xml rootElement] nodesForXPath:@"//property[@name='bog']/@value" error:nil] objectAtIndex:0] stringValue];
    
    NSString *opslag = [[[[xml rootElement] nodesForXPath:@"//property[@name='opslag']/@value" error:nil] objectAtIndex:0] stringValue];
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:50];
    NSUInteger count = 1;
    for (NSString *i in [opslag componentsSeparatedByString:@","]) {
        if (![i isEqualToString:@""]) {
            NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"Opslag %d", count++], AGMetadataImageNameKey, 
                                  [[remoteBasePath stringByAppendingString:i] substringFromIndex:1], AGMetadataImageKeyKey,
                                  nil
                                 ];
            [items addObject:item];
        }
    }
    
    [metadata setObject:items forKey:AGMetadataItemsKey];
    
    [[self metadataTarget] pluginNamed:AOPluginName didLoadMetadata:metadata];
}

#pragma mark WebPolicyDecisionListener

- (void)webView:(WebView *)sender decidePolicyForMIMEType:(NSString *)type request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id < WebPolicyDecisionListener >)listener
{
	//NSLog(@"Request (webView): %@\n%@\n%@", [request URL], [request allHTTPHeaderFields], [request HTTPBody]);
	// [type isEqualTo:@"application/x-java-jnlp-file"]
	if ([[[[request URL] absoluteString] lastPathComponent] isEqual:@"ViewImage.aspx"]) {
        [progressIndicator setIndeterminate:YES];
        [progressIndicator startAnimation:self];
        
        //NSLog(@"Request (webView): %@\n%@\n%@", [request URL], [request allHTTPHeaderFields], [request HTTPBody]);
		NSURLConnection *connectionResponse = [[NSURLConnection alloc]
											   initWithRequest:request delegate:self];
		if (!connectionResponse) {
			NSLog(@"Failed to submit request");
		} else {
			NSLog(@"Request submitted");
			NSURLResponse * response;
			NSError * error;
			
			NSData * myData = [NSURLConnection sendSynchronousRequest:request  
													returningResponse:&response error:&error];
			
            //NSLog(@"[self tableInfo]: %@", [self tableInfo]);
			[self prepareXML:[[NSXMLDocument alloc] initWithData:myData options:NSXMLDocumentTidyXML error:nil] withTags:[self tableInfo]];
            //[windowController close];
		}
		
		[listener ignore];
        [progressIndicator stopAnimation:self];
	} else  {
		[listener use];
	}
}

#pragma mark WebView notifications

- (void)webViewDidStart:(NSNotification*)notification
{
    //NSLog(@"[aoWebView estimatedProgress]: %f", [aoWebView estimatedProgress]);
    [progressIndicator setIndeterminate:YES];
    [progressIndicator startAnimation:self];
    [progressIndicator setDoubleValue:0.0];
}

- (void)webViewDidUpdate:(NSNotification*)notification
{
    if ([progressIndicator isIndeterminate]) {
        [progressIndicator setIndeterminate:NO];
        [progressIndicator stopAnimation:self];
    }
    [progressIndicator setDoubleValue:[aoWebView estimatedProgress]];
}

- (void)webViewDidFinish:(NSNotification*)notification
{
    //NSLog(@"[aoWebView estimatedProgress]: %f", [aoWebView estimatedProgress]);
    [progressIndicator setDoubleValue:1.0];    
}

#pragma mark Properties

- (NSString *)sessionID
{
    if (__sessionID == nil) {
        NSURL *aoURL = [NSURL URLWithString:@"http://www.sa.dk/ao/SoegeSider/Folketaelling.aspx"];
        
        NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:aoURL];
        NSHTTPURLResponse *resp;
        NSError *error;
        
        [NSURLConnection sendSynchronousRequest:req
                              returningResponse:&resp
                                          error:&error];
        
        if (error) {
            NSLog(@"error: %@", error);
        }
        
        for (NSHTTPCookie *cookie in [NSHTTPCookie cookiesWithResponseHeaderFields:[resp allHeaderFields] forURL:aoURL]) {
            if ([[cookie name] isEqualToString:@"ASP.NET_SessionId"]) {
                __sessionID = [cookie value];
            }
        }
        
        if (__sessionID == nil) {
            NSLog(@"Could not obtain SessionID");
        } else {
            NSLog(@"Got sessionID: %@", __sessionID);
        }
    }
    return __sessionID;
}

- (void)resetSessionID
{
    __sessionID = nil;
}

- (WebView *)aoWebView
{
    return aoWebView;
}

@synthesize service;
@synthesize status;
@synthesize metadataTarget;
@synthesize tableInfo;

@end
