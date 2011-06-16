/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIXMLIOService.m
//  NScaleApp
//
//  Created by Randall Wood on 4/5/2011.
//

#import "JMRIXMLIOService.h"
#import "JMRIXMLIOServiceHelper.h"

NSString *const JMRIXMLIOTypeMemory = @"memory";
NSString *const JMRIXMLIOTypeMetadata = @"metadata";
NSString *const JMRIXMLIOTypePanel = @"panel";
NSString *const JMRIXMLIOTypePower = @"power";
NSString *const JMRIXMLIOTypeRoster = @"roster";
NSString *const JMRIXMLIOTypeRoute = @"route";
NSString *const JMRIXMLIOTypeSensor = @"sensor";
NSString *const JMRIXMLIOTypeTurnout = @"turnout";

NSString *const JMRIXMLIOItemName = @"name";
NSString *const JMRIXMLIOItemType = @"type";
NSString *const JMRIXMLIOItemUserName = @"userName";
NSString *const JMRIXMLIOItemValue = @"value";

NSString *const JMRIXMLIOThrottleAddress = @"address";
NSString *const JMRIXMLIOThrottleForward = @"forward";
NSString *const JMRIXMLIOThrottleSpeed = @"speed";
NSString *const JMRIXMLIOThrottleF0 = @"F0";
NSString *const JMRIXMLIOThrottleF1 = @"F1";
NSString *const JMRIXMLIOThrottleF2 = @"F2";
NSString *const JMRIXMLIOThrottleF3 = @"F3";
NSString *const JMRIXMLIOThrottleF4 = @"F4";
NSString *const JMRIXMLIOThrottleF5 = @"F5";
NSString *const JMRIXMLIOThrottleF6 = @"F6";
NSString *const JMRIXMLIOThrottleF7 = @"F7";
NSString *const JMRIXMLIOThrottleF8 = @"F8";
NSString *const JMRIXMLIOThrottleF9 = @"F9";
NSString *const JMRIXMLIOThrottleF10 = @"F10";
NSString *const JMRIXMLIOThrottleF11 = @"F11";
NSString *const JMRIXMLIOThrottleF12 = @"F12";

// Well known sensor and memory names
NSString *const JMRIXMLIOMemoryCurrentTime = @"IMCURRENTTIME";
NSString *const JMRIXMLIOMemoryRateFactor = @"IMRATEFACTOR";
NSString *const JMRIXMLIOMetadataJMRIVersion = @"JMRIVERSION";
NSString *const JMRIXMLIOMetadataJVMVendor = @"JVMVENDOR";
NSString *const JMRIXMLIOMetadataJVMVersion = @"JVMVERSION";
NSString *const JMRIXMLIOSensorClockRunning = @"ISCLOCKRUNNING";

// NSNotification posting
NSString *const JMRIXMLIOServiceDidListItems = @"JMRIXMLIOServiceDidListItems";
NSString *const JMRIXMLIOServiceDidReadItem = @"JMRIXMLIOServiceDidReadItem";
NSString *const JMRIXMLIOServiceDidWriteItem = @"JMRIXMLIOServiceDidWriteItem";
NSString *const JMRIXMLIOItemsListKey = @"JMRIXMLIOItemsListKey";
NSString *const JMRIXMLIOItemKey = @"JMRIXMLIOItemKey";
NSString *const JMRIXMLIOItemNameKey = @"JMRIXMLIOItemNameKey";
NSString *const JMRIXMLIOItemTypeKey = @"JMRIXMLIOItemTypeKey";
NSString *const JMRIXMLIOItemValueKey = @"JMRIXMLIOItemValueKey";

#pragma mark -
#pragma mark Private interface

@interface JMRIXMLIOService () <JMRIXMLIOServiceHelperDelegate>

- (void)conductOperation:(NSUInteger)operation 
		   withXMLString:(NSString *)query 
				withType:(NSString *)type
				withName:(NSString *)aName;

@end

#pragma mark -

@implementation JMRIXMLIOService

#pragma mark -
#pragma mark Properties

@synthesize XMLIOPath = _XMLIOPath;

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
		[self readItem:JMRIXMLIOMetadataJMRIVersion ofType:JMRIXMLIOTypeMetadata];
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
		JMRIXMLIOServiceHelper *helper = [[JMRIXMLIOServiceHelper alloc] init];
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
				NSLog(@"JMRIXMLIOService opened new connection. %i connections are open.", connections);
			}
			if ([self.delegate respondsToSelector:@selector(JMRIXMLIOService:didConnectWithRequest:)]) {
				[self.delegate JMRIXMLIOService:self didConnectWithRequest:request];
			}
		} else { // failed to create NSURLConnection object
			[self.delegate JMRIXMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1027 userInfo:nil]];
		}
	} else if (!self.url) { // did not resolve
		[self.delegate JMRIXMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1025 userInfo:nil]];
	} else { // open connection
		[self.delegate JMRIXMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1026 userInfo:nil]];
	}
}

- (void)list:(NSString *)type {
		[self conductOperation:JMRIXMLIOOperationList
				 withXMLString:[NSString stringWithFormat:@"<list><type>%@</type></list>", type]
					  withType:type
					  withName:nil];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
	[self conductOperation:JMRIXMLIOOperationRead
			 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name></item>", type, name]
				  withType:type
				  withName:name];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
	[self conductOperation:JMRIXMLIOOperationRead
			 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name><value>%@</value></item>", type, name, value]
				  withType:type
				  withName:name];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
	[self conductOperation:JMRIXMLIOOperationWrite
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

- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didFailWithError:(NSError *)error {
	connections--;
	if ([error code] == NSURLErrorTimedOut &&
		[monitoredItems containsObject:[helper.name stringByAppendingString:helper.type]]) {
		[self readItem:helper.name ofType:helper.type];
	}
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOService:didFailWithError:)]) {
		[self.delegate JMRIXMLIOService:self didFailWithError:error];
	}
	if (self.logTraffic) {
		NSLog(@"JMRIXMLIOService connection failed. %i connections remain open.", connections);
	}
}

- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type {
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOService:didListItems:ofType:)]) {
		[self.delegate JMRIXMLIOService:self didListItems:items ofType:type];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:JMRIXMLIOServiceDidListItems
														object:self
													  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																items, JMRIXMLIOItemsListKey,
																type, JMRIXMLIOItemTypeKey,
																nil]];
}

- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didReadItem:(JMRIXMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOService:didReadItem:withName:ofType:withValue:)]) {
		[self.delegate JMRIXMLIOService:self didReadItem:item withName:name ofType:type withValue:value];
	}
	if ([monitoredItems containsObject:[name stringByAppendingString:type]]) {
		[self readItem:name ofType:type initialValue:value];
	}
	if (value) {
		[[NSNotificationCenter defaultCenter] postNotificationName:JMRIXMLIOServiceDidReadItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, JMRIXMLIOItemKey,
																	name, JMRIXMLIOItemNameKey,
																	type, JMRIXMLIOItemTypeKey,
																	value, JMRIXMLIOItemValueKey,
																	nil]];
	}
}

- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didWriteItem:(JMRIXMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOService:didWriteItem:ofType:withValue:)]) {
		[self.delegate JMRIXMLIOService:self didWriteItem:item withName:name ofType:type withValue:value];
	}
	if (value) {
		[[NSNotificationCenter defaultCenter] postNotificationName:JMRIXMLIOServiceDidWriteItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, JMRIXMLIOItemKey,
																	name, JMRIXMLIOItemNameKey,
																	type, JMRIXMLIOItemTypeKey,
																	value, JMRIXMLIOItemValueKey,
																	nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:JMRIXMLIOServiceDidReadItem
															object:self
														  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	item, JMRIXMLIOItemKey,
																	name, JMRIXMLIOItemNameKey,
																	type, JMRIXMLIOItemTypeKey,
																	value, JMRIXMLIOItemValueKey,
																	nil]];
	}
}

- (void)JMRIXMLIOServiceHelperDidFinishLoading:(JMRIXMLIOServiceHelper *)helper {
	connections--;
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceDidFinishLoading:)]) {
		[self.delegate JMRIXMLIOServiceDidFinishLoading:self];
	}
	if (self.logTraffic) {
		NSLog(@"JMRIXMLIOService has just closed a connection. %i connections remain open.", connections);
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
