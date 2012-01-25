//
//  NSMutableArray+Soap.h
//  SudzCExamples
//
//  Created by Jason Kichline on 12/14/10.
//  Copyright 2010 andCulture. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface NSMutableArray (Soap)

+(NSMutableArray*)newWithNode: (NSXMLNode*) node;
-(id)initWithNode:(NSXMLNode*)node;
+(NSMutableString*) serialize: (NSArray*) array;
-(id)object;

@end
