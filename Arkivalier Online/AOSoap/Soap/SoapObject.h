/*
 SoapObject.h
 Interface for the SoapObject base object that provides initialization and deallocation methods.
 Authors: Jason Kichline, andCulture - Harrisburg, Pennsylvania USA
          Karl Schulenburg, UMAI Development - Shoreditch, London UK
*/

#import <Cocoa/Cocoa.h>

@interface SoapObject : NSObject {
}

@property (readonly) id object;

+ (id) newWithNode: (NSXMLNode*) node;
- (id) initWithNode: (NSXMLNode*) node;
- (NSMutableString*) serialize;
- (NSMutableString*) serialize: (NSString*) nodeName;
- (NSMutableString*) serializeElements;
- (NSMutableString*) serializeAttributes;

@end