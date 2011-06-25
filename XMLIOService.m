/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOService.m
//  NScaleApp
//
//  Created by Randall Wood on 4/5/2011.
//

#import "XMLIOService.h"
#import "XMLIOServiceHelper.h"

NSString *const XMLIOTypeMemory = @"memory";
NSString *const XMLIOTypeMetadata = @"metadata";
NSString *const XMLIOTypePanel = @"panel";
NSString *const XMLIOTypePower = @"power";
NSString *const XMLIOTypeRoster = @"roster";
NSString *const XMLIOTypeRoute = @"route";
NSString *const XMLIOTypeSensor = @"sensor";
NSString *const XMLIOTypeTurnout = @"turnout";

NSString *const XMLIOItemComment = @"comment";
NSString *const XMLIOItemInverted = @"inverted";
NSString *const XMLIOItemName = @"name";
NSString *const XMLIOItemType = @"type";
NSString *const XMLIOItemUserName = @"userName";
NSString *const XMLIOItemValue = @"value";

NSString *const XMLIORosterDCCAddress = @"dccAddress";
NSString *const XMLIORosterAddressLength = @"addressLength";
NSString *const XMLIORosterRoadName = @"roadName";
NSString *const XMLIORosterRoadNumber = @"roadNumber";
NSString *const XMLIORosterMFG = @"mfg";
NSString *const XMLIORosterModel = @"model";
NSString *const XMLIORosterMaxSpeedPct = @"maxSpeedPct";
NSString *const XMLIORosterImageFileName = @"imageFileName";
NSString *const XMLIORosterImageIconName = @"imageIconName";
NSString *const XMLIORosterFunctions = @"functions";

NSString *const XMLIOThrottleAddress = @"address";
NSString *const XMLIOThrottleForward = @"forward";
NSString *const XMLIOThrottleSpeed = @"speed";
NSString *const XMLIOThrottleF0 = @"F0";
NSString *const XMLIOThrottleF1 = @"F1";
NSString *const XMLIOThrottleF2 = @"F2";
NSString *const XMLIOThrottleF3 = @"F3";
NSString *const XMLIOThrottleF4 = @"F4";
NSString *const XMLIOThrottleF5 = @"F5";
NSString *const XMLIOThrottleF6 = @"F6";
NSString *const XMLIOThrottleF7 = @"F7";
NSString *const XMLIOThrottleF8 = @"F8";
NSString *const XMLIOThrottleF9 = @"F9";
NSString *const XMLIOThrottleF10 = @"F10";
NSString *const XMLIOThrottleF11 = @"F11";
NSString *const XMLIOThrottleF12 = @"F12";

// Well known sensor and memory names
NSString *const XMLIOMemoryCurrentTime = @"IMCURRENTTIME";
NSString *const XMLIOMemoryRateFactor = @"IMRATEFACTOR";
NSString *const XMLIOMetadataJMRIVersion = @"JMRIVERSION";
NSString *const XMLIOMetadataJVMVendor = @"JVMVENDOR";
NSString *const XMLIOMetadataJVMVersion = @"JVMVERSION";
NSString *const XMLIOSensorClockRunning = @"ISCLOCKRUNNING";

// NSNotification posting
NSString *const XMLIOServiceDidListItems = @"XMLIOServiceDidListItems";
NSString *const XMLIOServiceDidReadItem = @"XMLIOServiceDidReadItem";
NSString *const XMLIOServiceDidWriteItem = @"XMLIOServiceDidWriteItem";
NSString *const XMLIOItemsListKey = @"XMLIOItemsListKey";
NSString *const XMLIOItemKey = @"XMLIOItemKey";
NSString *const XMLIOItemNameKey = @"XMLIOItemNameKey";
NSString *const XMLIOItemTypeKey = @"XMLIOItemTypeKey";
NSString *const XMLIOItemValueKey = @"XMLIOItemValueKey";

#pragma mark -
#pragma mark Private interface

@interface XMLIOService () <XMLIOServiceHelperDelegate>

- (void)conductOperation:(NSUInteger)operation 
		   withXMLString:(NSString *)query 
				withType:(NSString *)type
				withName:(NSString *)aName;

@end

#pragma mark -

@implementation XMLIOService

#pragma mark -
#pragma mark Properties

@synthesize XMLIOPath;

- (BOOL)openConnection {
	return (connections);
}

- (NSURL *)url {
	if (self.port == -1) {
		return nil;
	}
	if (![self.XMLIOPath hasPrefix:@"/"]) {
		self.XMLIOPath = [@"/" stringByAppendingString:self.XMLIOPath];
	}
	return [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i%@", self.hostname, self.port, self.XMLIOPath, nil]] absoluteURL];
}

#pragma mark -
#pragma mark JMRI net service methods

- (BOOL)testConnection {
	if (self.port) {
		[self readItem:XMLIOMetadataJMRIVersion ofType:XMLIOTypeMetadata];
		return YES;
	}
	return NO;
}

#pragma mark -
#pragma mark XMLIO methods

- (void)conductOperation:(NSUInteger)operation 
		   withXMLString:(NSString *)query 
				withType:(NSString *)type
				withName:(NSString *)aName {
	if (self.url) {
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url
															   cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														   timeoutInterval:self.timeoutInterval];
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<xmlio>%@</xmlio>", query]
							  dataUsingEncoding:NSUTF8StringEncoding]];
		if (self.logTraffic) {
			NSLog(@"Sending %@ to %@", [NSString stringWithUTF8String:[[request HTTPBody] bytes]], self.url);
		}
		XMLIOServiceHelper *helper = [[XMLIOServiceHelper alloc] init];
		helper.request = request;
		helper.delegate = self;
		helper.name = aName;
		helper.operation = operation;
		helper.type = type;
		NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:helper];
		[helper release];
		if (connection) {
			connections++;
			if (self.logTraffic) {
				NSLog(@"XMLIOService opened new connection. %lu connections are open.", (unsigned long)connections);
			}
			if ([self.delegate respondsToSelector:@selector(XMLIOService:didConnectWithRequest:)]) {
				[self.delegate XMLIOService:self didConnectWithRequest:request];
			}
		} else { // failed to create NSURLConnection object
			[self.delegate XMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1027 userInfo:nil]];
		}
	} else if (!self.url) { // did not resolve
		[self.delegate XMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1025 userInfo:nil]];
	} else { // open connection
		[self.delegate XMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1026 userInfo:nil]];
	}
}

- (void)list:(NSString *)type {
		[self conductOperation:XMLIOOperationList
				 withXMLString:[NSString stringWithFormat:@"<list><type>%@</type></list>", type]
					  withType:type
					  withName:nil];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
	[self conductOperation:XMLIOOperationRead
			 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name></item>", type, name]
				  withType:type
				  withName:name];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
	[self conductOperation:XMLIOOperationRead
			 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name><value>%@</value></item>", type, name, value]
				  withType:type
				  withName:name];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
	[self conductOperation:XMLIOOperationWrite
			 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name><set>%@</set></item>", type, name, value]
				  withType:type
				  withName:name];
}

- (void)startMonitoring:(NSString *)name ofType:(NSString *)type {
	if (![monitoredItems containsObject:[name stringByAppendingString:type]]) {
		[monitoredItems addObject:[name stringByAppendingString:type]];
		[self readItem:name ofType:type];
	}
}

- (void)stopMonitoring:(NSString *)name ofType:(NSString *)type {
	[monitoredItems removeObject:[name stringByAppendingString:type]];
}

- (void)stopMonitoringAllItems {
	[monitoredItems removeAllObjects];
}

#pragma mark -
#pragma mark JMRI XMLIO service helper delegate

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didFailWithError:(NSError *)error {
	connections--;
	if ([error code] == NSURLErrorTimedOut &&
		[monitoredItems containsObject:[helper.name stringByAppendingString:helper.type]]) {
		[self readItem:helper.name ofType:helper.type];
	}
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didFailWithError:)]) {
		[self.delegate XMLIOService:self didFailWithError:error];
	}
	if (self.logTraffic) {
		NSLog(@"XMLIOService connection failed. %lu connections remain open.", (unsigned long)connections);
	}
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type {
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didListItems:ofType:)]) {
		[self.delegate XMLIOService:self didListItems:items ofType:type];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:XMLIOServiceDidListItems
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																items, XMLIOItemsListKey,
																type, XMLIOItemTypeKey,
																nil]];
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didReadItem:(XMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didReadItem:withName:ofType:withValue:)]) {
		[self.delegate XMLIOService:self didReadItem:item withName:name ofType:type withValue:value];
	}
	if ([monitoredItems containsObject:[name stringByAppendingString:type]]) {
		[self readItem:name ofType:type initialValue:value];
	}
	if (value) {
		[[NSNotificationCenter defaultCenter] postNotificationName:XMLIOServiceDidReadItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, XMLIOItemKey,
																	name, XMLIOItemNameKey,
																	type, XMLIOItemTypeKey,
																	value, XMLIOItemValueKey,
																	nil]];
	}
    if ([name isEqualToString:XMLIOMetadataJMRIVersion] && value) {
        version_ = value;
    }
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didWriteItem:(XMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didWriteItem:ofType:withValue:)]) {
		[self.delegate XMLIOService:self didWriteItem:item withName:name ofType:type withValue:value];
	}
	if (value) {
		[[NSNotificationCenter defaultCenter] postNotificationName:XMLIOServiceDidWriteItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, XMLIOItemKey,
																	name, XMLIOItemNameKey,
																	type, XMLIOItemTypeKey,
																	value, XMLIOItemValueKey,
																	nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:XMLIOServiceDidReadItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, XMLIOItemKey,
																	name, XMLIOItemNameKey,
																	type, XMLIOItemTypeKey,
																	value, XMLIOItemValueKey,
																	nil]];
	}
}

- (void)XMLIOServiceHelperDidFinishLoading:(XMLIOServiceHelper *)helper {
	connections--;
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceDidFinishLoading:)]) {
		[self.delegate XMLIOServiceDidFinishLoading:self];
	}
	if (self.logTraffic) {
		NSLog(@"XMLIOService has just closed a connection. %lu connections remain open.", (unsigned long)connections);
	}
}

#pragma mark -
#pragma mark Net service delegate

// do not override superclass

#pragma mark -
#pragma mark Object management

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super initWithNetService:service])) {
		connections = 0;
		monitoredItems = [[NSMutableSet alloc] initWithCapacity:0];
		self.XMLIOPath = @"xmlio";
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super initWithAddress:address withPort:port])) {
		connections = 0;
		monitoredItems = [[NSMutableSet alloc] initWithCapacity:0];
		self.XMLIOPath = @"xmlio";
	}
	return self;
}

- (void)dealloc {
	[monitoredItems release];
	self.XMLIOPath = nil;
	[super dealloc];
}

@end
