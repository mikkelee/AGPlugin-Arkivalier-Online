/*
	AOService1.m
	The implementation classes and methods for the Service1 web service.
	Generated by SudzC.com
*/

#import "AOService1.h"
				
#import "Soap.h"
	
#import "AOGetImageResponse.h"

/* Implementation of the service */
				
@implementation AOService1

	- (id) init
	{
		if(self = [super init])
		{
			self.serviceUrl = @"http://ao.sa.dk/LAView/ImageServer/Service1.asmx";
			self.namespace = @"http://arkivalieronline.dk/ao/webservices/";
			self.headers = nil;
			self.logging = NO;
		}
		return self;
	}
	
	- (id) initWithUsername: (NSString*) username andPassword: (NSString*) password {
		if(self = [super initWithUsername:username andPassword:password]) {
		}
		return self;
	}
	
	+ (AOService1*) service {
		return [AOService1 serviceWithUsername:nil andPassword:nil];
	}
	
	+ (AOService1*) serviceWithUsername: (NSString*) username andPassword: (NSString*) password {
		return [[AOService1 alloc] initWithUsername:username andPassword:password];
	}

		
	/* Returns AOGetImageResponse*.  */
	- (SoapRequest*) getImage2: (id <SoapDelegate>) handler sessionId: (NSString*) sessionId name: (NSString*) name
	{
		return [self getImage2: handler action: nil sessionId: sessionId name: name];
	}

	- (SoapRequest*) getImage2: (id) _target action: (SEL) _action sessionId: (NSString*) sessionId name: (NSString*) name
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[SoapParameter alloc] initWithValue: sessionId forName: @"sessionId"]];
		[_params addObject: [[SoapParameter alloc] initWithValue: name forName: @"name"]];
		NSString* _envelope = [Soap createEnvelope: @"getImage2" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"http://arkivalieronline.dk/ao/webservices/getImage2" postData: _envelope deserializeTo: [AOGetImageResponse alloc]];
		[_request send];
		return _request;
	}

	/* Returns AOGetImageResponse*.  */
	- (SoapRequest*) getImage: (id <SoapDelegate>) handler email: (NSString*) email password: (NSString*) password name: (NSString*) name
	{
		return [self getImage: handler action: nil email: email password: password name: name];
	}

	- (SoapRequest*) getImage: (id) _target action: (SEL) _action email: (NSString*) email password: (NSString*) password name: (NSString*) name
		{
		NSMutableArray* _params = [NSMutableArray array];
		
		[_params addObject: [[SoapParameter alloc] initWithValue: email forName: @"email"]];
		[_params addObject: [[SoapParameter alloc] initWithValue: password forName: @"password"]];
		[_params addObject: [[SoapParameter alloc] initWithValue: name forName: @"name"]];
		NSString* _envelope = [Soap createEnvelope: @"getImage" forNamespace: self.namespace withParameters: _params withHeaders: self.headers];
		SoapRequest* _request = [SoapRequest create: _target action: _action service: self soapAction: @"http://arkivalieronline.dk/ao/webservices/getImage" postData: _envelope deserializeTo: [AOGetImageResponse alloc]];
		[_request send];
		return _request;
	}


@end
	