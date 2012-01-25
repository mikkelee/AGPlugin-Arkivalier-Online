//
//  NSMutableArray+Soap.m
//  SudzCExamples
//
//  Created by Jason Kichline on 12/14/10.
//  Copyright 2010 andCulture. All rights reserved.
//

#import "NSMutableArray+Soap.h"
#import "Soap.h"

@implementation NSMutableArray (Soap)

+(NSMutableArray*)newWithNode: (NSXMLNode*) node {
	return [[self alloc] initWithNode:node];
}

-(id)initWithNode:(NSXMLNode*)node {
	if(self = [self init]) {
		for(NSXMLNode* child in [node children]) {
			[self addObject:[Soap deserialize:child]];
		}
	}
	return self;
}

-(id)object { return self; }

+ (NSMutableString*) serialize: (NSArray*) array {
	return [NSMutableString stringWithString:[Soap serialize:array]];
}

@end
