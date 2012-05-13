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

#if TARGET_OS_IPHONE        
#import <UIKit/UIKit.h>
#define RESPONDER UIResponder
#else
#import <Cocoa/Cocoa.h>
#define RESPONDER NSResponder
#endif //TARGET_OS_IPHONE

#import "XMLIOService.h"
#import "XMLIOServiceHelper.h"
#import "XMLIOThrottle.h"
#import "XMLIOMetadata.h"

NSString *const JMRITypeThrottle = @"throttle";

NSString *const XMLIOItemComment = @"comment";
NSString *const XMLIOItemInverted = @"inverted";
NSString *const XMLIOItemName = @"name";
NSString *const XMLIOItemType = @"type";
NSString *const XMLIOItemUserName = @"userName";
NSString *const XMLIOItemValue = @"value";
NSString *const XMLIOItemIsNull = @"isNull";

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
NSUInteger const XMLIORosterMaxFunctions = 29; // F0 though F28

NSString *const XMLIOThrottleAddress = @"address";
NSString *const XMLIOThrottleForward = @"forward";
NSString *const XMLIOThrottleSpeed = @"speed";
NSString *const XMLIOThrottleSpeedStepMode = @"SSM";
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
NSString *const XMLIOThrottleF13 = @"F13";
NSString *const XMLIOThrottleF14 = @"F14";
NSString *const XMLIOThrottleF15 = @"F15";
NSString *const XMLIOThrottleF16 = @"F16";
NSString *const XMLIOThrottleF17 = @"F17";
NSString *const XMLIOThrottleF18 = @"F18";
NSString *const XMLIOThrottleF19 = @"F19";
NSString *const XMLIOThrottleF20 = @"F20";
NSString *const XMLIOThrottleF21 = @"F21";
NSString *const XMLIOThrottleF22 = @"F22";
NSString *const XMLIOThrottleF23 = @"F23";
NSString *const XMLIOThrottleF24 = @"F24";
NSString *const XMLIOThrottleF25 = @"F25";
NSString *const XMLIOThrottleF26 = @"F26";
NSString *const XMLIOThrottleF27 = @"F27";
NSString *const XMLIOThrottleF28 = @"F28";

// Well known sensor and memory names
NSString *const XMLIOMemoryCurrentTime = @"IMCURRENTTIME";
NSString *const XMLIOMemoryRateFactor = @"IMRATEFACTOR";
NSString *const XMLIOMetadataJMRIVersion = @"JMRIVERSION";
NSString *const XMLIOMetadataJVMVendor = @"JVMVENDOR";
NSString *const XMLIOMetadataJVMVersion = @"JVMVERSION";
NSString *const XMLIOMetadataVersionMajor = @"major";
NSString *const XMLIOMetadataVersionMinor = @"minor";
NSString *const XMLIOMetadataVersionTest = @"test";
NSString *const XMLIOSensorClockRunning = @"ISCLOCKRUNNING";

// NSNotification posting
NSString *const XMLIOServiceDidListItems = @"XMLIOServiceDidListItems";
NSString *const XMLIOServiceDidReadItem = @"XMLIOServiceDidReadItem";
NSString *const XMLIOServiceDidWriteItem = @"XMLIOServiceDidWriteItem";
NSString *const XMLIOServiceDidGetThrottle = @"XMLIOServiceDidGetThrottle";
NSString *const XMLIOItemsListKey = @"XMLIOItemsListKey";
NSString *const XMLIOItemKey = @"XMLIOItemKey";
NSString *const XMLIOItemNameKey = @"XMLIOItemNameKey";
NSString *const XMLIOItemTypeKey = @"XMLIOItemTypeKey";
NSString *const XMLIOItemValueKey = @"XMLIOItemValueKey";
NSString *const XMLIOThrottleKey = @"XMLIOThrottleKey";

// NSError keys
NSString *const XMLIOErrorDomain = @"XMLIOErrorDomain";

// Javaisms
NSString *const XMLIOBooleanYES = @"true"; // java.lang.Boolean.toString returns "true" for YES
NSString *const XMLIOBooleanNO = @"false"; // java.lang.Boolean.toString returns "false" for NO

#pragma mark - Private interface

@interface XMLIOService () <XMLIOServiceHelperDelegate>

- (void)conductOperation:(NSUInteger)operation 
		   withXMLString:(NSString *)query 
				withType:(NSString *)type
				withName:(NSString *)aName;
- (void)readItemFromTimer:(NSTimer *)timer;

@end

#pragma mark -

@implementation XMLIOService

#pragma mark - Properties

@synthesize XMLIOPath;
@synthesize throttles;
@synthesize monitoringDelay;

- (BOOL)openConnection {
	return ([connections count]);
}

- (NSURL *)url {
	if (self.port == -1) {
		return nil;
	}
	if (![self.XMLIOPath hasPrefix:@"/"]) {
		self.XMLIOPath = [@"/" stringByAppendingString:self.XMLIOPath];
	}
    if (![self.XMLIOPath hasSuffix:@"/"]) {
        self.XMLIOPath = [self.XMLIOPath stringByAppendingString:@"/"];
    }
	return [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i%@", self.hostName, self.port, self.XMLIOPath, nil]] absoluteURL];
}

- (BOOL)useAttributeProtocol {
    return ([self.version compare:@"2.13.2" options:NSNumericSearch] != NSOrderedAscending);
}

#pragma mark - XMLIO methods

- (void)conductOperation:(NSUInteger)operation 
		   withXMLString:(NSString *)query 
				withType:(NSString *)type
				withName:(NSString *)aName {
    if (!self.useAttributeProtocol && operation != XMLIOOperationList && [type isEqualToString:JMRITypeMetadata]) {
        return;
    }
	if (self.url) {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:self.url
                                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                           timeoutInterval:self.timeoutInterval];
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[[NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><xmlio>%@</xmlio>", query]
                              dataUsingEncoding:NSUTF8StringEncoding]];
        if (self.logTraffic) {
            NSLog(@"Sending %@ to %@", [NSString stringWithUTF8String:[[request HTTPBody] bytes]], self.url);
        }
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        XMLIOServiceHelper *helper = [[XMLIOServiceHelper alloc] initWithDelegate:self
                                                                     withOperation:operation
                                                                       withRequest:request
                                                                          withType:type
                                                                          withName:aName];
        [queue addOperation:helper];
	} else if (!self.url) { // did not resolve
		[self.delegate XMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1025 userInfo:nil]];
	} else { // open connection
		[self.delegate XMLIOService:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1026 userInfo:nil]];
	}
}

- (void)readItemFromTimer:(NSTimer *)timer {
    [self readItem:[[timer userInfo] objectForKey:XMLIOItemNameKey]
            ofType:[[timer userInfo] objectForKey:XMLIOItemTypeKey]
      initialValue:[[timer userInfo] objectForKey:XMLIOItemValueKey]];
}

- (void)list:(NSString *)type {
    if (self.useAttributeProtocol) {
        [self conductOperation:XMLIOOperationList
                 withXMLString:[NSString stringWithFormat:@"<list type=\"%@\" />", type]
                      withType:type
                      withName:nil];
    } else {
        if ([type isEqualToString:JMRITypeFrame]) {
            type = JMRITypePanel;
        }
		[self conductOperation:XMLIOOperationList
				 withXMLString:[NSString stringWithFormat:@"<list><type>%@</type></list>", type]
					  withType:type
					  withName:nil];
    }
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    if (self.useAttributeProtocol || [type isEqualToString:JMRITypeMetadata]) {
        [self conductOperation:XMLIOOperationRead
                 withXMLString:[NSString stringWithFormat:@"<%@ name=\"%@\" />", type, name]
                      withType:type
                      withName:name];
    } else {
        [self conductOperation:XMLIOOperationRead
                 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name></item>", type, name]
                      withType:type
                      withName:name];
    }
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
    if (self.useAttributeProtocol || [type isEqualToString:JMRITypeMetadata]) {
        [self conductOperation:XMLIOOperationRead
                 withXMLString:[NSString stringWithFormat:@"<%@ name=\"%@\" value=\"%@\" />", type, name, value]
                      withType:type
                      withName:name];
    } else {
        [self conductOperation:XMLIOOperationRead
                 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name><value>%@</value></item>", type, name, value]
                      withType:type
                      withName:name];
    }
    if (self.logTraffic) {
        NSLog(@"Monitoring: %@", monitoredItems);
        NSLog(@"Open Requests:");
        for (NSData *key in [connections allKeys]) {
            NSLog(@"%@", [NSString stringWithUTF8String:[key bytes]]);
        }
    }
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    if (self.useAttributeProtocol) {
        [self conductOperation:XMLIOOperationWrite
                 withXMLString:[NSString stringWithFormat:@"<%@ name=\"%@\" set=\"%@\" />", type, name, value]
                      withType:type
                      withName:name];
    } else {
        [self conductOperation:XMLIOOperationWrite
                 withXMLString:[NSString stringWithFormat:@"<item><type>%@</type><name>%@</name><set>%@</set></item>", type, name, value]
                      withType:type
                      withName:name];
    }
}

- (void)sendThrottle:(NSUInteger)address commands:(NSDictionary *)commands {
    NSMutableString *s;
    if (self.useAttributeProtocol) {
        s = [NSMutableString stringWithFormat:@"<throttle address=\"%lu\"", address];
        if (commands) {
            for (NSString *key in commands) {
                [s appendFormat:@" %@=\"%@\"", key, [commands objectForKey:key]];
            }
        }
        [s appendString:@"/>"];
    } else {
        s = [NSMutableString stringWithFormat:@"<throttle><address>%lu</address>", address];
        if (commands) {
            for (NSString *key in commands) {
                [s appendFormat:@"<%@>%@</%@>", key, [commands objectForKey:key], key];
            }
        }
        [s appendString:@"</throttle>"];
    }
    [self conductOperation:XMLIOOperationThrottle 
             withXMLString:s 
                  withType:JMRITypeThrottle
                  withName:[[NSNumber numberWithUnsignedInteger:address] stringValue]];
}

- (void)stopThrottle:(NSUInteger)address {
    [self sendThrottle:address commands:[NSDictionary dictionaryWithObject:@"0" forKey:XMLIOThrottleSpeed]];
}

- (void)stopAllThrottles {
    for (NSString *address in self.throttles) {
        [self stopThrottle:[address integerValue]];
    }
}

- (void)startMonitoring:(NSString *)name ofType:(NSString *)type {
	if (![type isEqualToString:JMRITypeFrame] &&
        ![type isEqualToString:JMRITypeRoster] &&
        ![type isEqualToString:JMRITypeMetadata] &&
        ![monitoredItems containsObject:[name stringByAppendingString:type]]) {
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

- (void)cancelAllConnections {
    for (NSURLRequest *request in connections) {
        [[connections objectForKey:request] cancel];
    }
    [connections removeAllObjects];
}

#pragma mark - JMRI XMLIO service rethreading

- (void)helperDidFail:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
            didFailWithError:[parameters objectForKey:@"error"]];
}

- (void)helperDidConnectWithRequest:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
       didConnectWithRequest:[parameters objectForKey:@"request"]];
}

- (void)helperDidListItems:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
                didListItems:[parameters objectForKey:@"items"]
                      ofType:[parameters objectForKey:@"type"]];
}

- (void)helperDidReadItem:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
                 didReadItem:[parameters objectForKey:@"item"]
                    withName:[parameters objectForKey:@"name"]
                      ofType:[parameters objectForKey:@"type"]
                   withValue:[parameters objectForKey:@"value"]];
}

- (void)helperDidWriteItem:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
                didWriteItem:[parameters objectForKey:@"item"]
                    withName:[parameters objectForKey:@"name"]
                      ofType:[parameters objectForKey:@"type"]
                   withValue:[parameters objectForKey:@"value"]];
}

- (void)helperDidGetThrottle:(NSDictionary *)parameters {
    [self XMLIOServiceHelper:[parameters objectForKey:@"helper"]
              didGetThrottle:[parameters objectForKey:@"throttle"]
                   atAddress:[[parameters objectForKey:@"address"] integerValue]];
}

#pragma mark - JMRI XMLIO service helper delegate

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didFailWithError:(NSError *)error {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidFail:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", error, @"error", nil]
                            waitUntilDone:NO];
        return;
    }
	[connections removeObjectForKey:[helper.request HTTPBody]];
	if ([error code] == NSURLErrorTimedOut &&
		[monitoredItems containsObject:[helper.name stringByAppendingString:helper.type]]) {
		[self readItem:helper.name ofType:helper.type];
	} else if ([error code] == NSURLErrorNetworkConnectionLost && 
               !self.useAttributeProtocol &&
               [monitoredItems containsObject:[helper.name stringByAppendingString:helper.type]]) {
        [monitoredItems removeObject:[helper.name stringByAppendingString:helper.type]];
    }
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didFailWithError:)]) {
		[self.delegate XMLIOService:self didFailWithError:error];
	}
	if (self.logTraffic) {
		NSLog(@"XMLIOService connection failed. %lu connections remain open. Failed with operation: %lu (%@, a %@)", (unsigned long)[connections count], (unsigned long)helper.operation, helper.name, helper.type);
	}
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didConnectWithRequest:(NSURLRequest *)request {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidConnectWithRequest:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", request, @"request", nil]
                            waitUntilDone:NO];
        return;
    }
    [connections setObject:helper forKey:[request HTTPBody]];
    if (self.logTraffic) {
        NSLog(@"XMLIOService opened new connection. %lu connections are open.", (unsigned long)[connections count]);
    }
    if ([self.delegate respondsToSelector:@selector(XMLIOService:didConnectWithRequest:)]) {
        [self.delegate XMLIOService:self didConnectWithRequest:request];
    }
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidListItems:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", items, @"items", type, @"type", nil]
                            waitUntilDone:NO];
        return;
    }
    NSLog(@"listing %lu %@s", (unsigned long)[items count], type);
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
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidReadItem:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", item, @"item", name, @"name", type, @"type", value, @"value", nil]
                            waitUntilDone:NO];
        return;
    }
	if ([self.delegate respondsToSelector:@selector(XMLIOService:didReadItem:withName:ofType:withValue:)]) {
		[self.delegate XMLIOService:self didReadItem:item withName:name ofType:type withValue:value];
	}
	if ([monitoredItems containsObject:[name stringByAppendingString:type]]) {
        if (self.monitoringDelay) {
            [NSTimer scheduledTimerWithTimeInterval:self.monitoringDelay
                                             target:self
                                           selector:@selector(readItemFromTimer:)
                                           userInfo:[NSDictionary dictionaryWithObjectsAndKeys:name,XMLIOItemNameKey, type, XMLIOItemTypeKey, value, XMLIOItemValueKey, nil]
                                            repeats:NO];
        } else {
            [self readItem:name ofType:type initialValue:value];            
        }
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
    if ([name isEqualToString:XMLIOMetadataJMRIVersion] && [[item class] isSubclassOfClass:[XMLIOMetadata class]] && [(XMLIOMetadata *)item majorVersion] != 0) {
        serviceVersion = [NSString stringWithFormat:@"%i.%i.%i", 
                           [(XMLIOMetadata *)item majorVersion],
                           [(XMLIOMetadata *)item minorVersion],
                           [(XMLIOMetadata *)item testVersion]];
        if (self.monitoringDelay == defaultMonitoringDelay) {
            defaultMonitoringDelay = (self.useAttributeProtocol) ? 0 : 5;
            self.monitoringDelay = defaultMonitoringDelay;
        }
    }
}

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didWriteItem:(XMLIOItem *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidWriteItem:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", item, @"item", name, @"name", type, @"type", value, @"value", nil]
                            waitUntilDone:NO];
        return;
    }
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

- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didGetThrottle:(XMLIOThrottle *)throttle atAddress:(NSUInteger)address {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(helperDidGetThrottle:) 
                               withObject:[NSDictionary dictionaryWithObjectsAndKeys:helper, @"helper", throttle, @"throttle", [NSNumber numberWithInteger:address], @"address", nil]
                            waitUntilDone:NO];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(XMLIOService:didGetThrottle:withAddress:)]) {
        [self.delegate XMLIOService:self didGetThrottle:throttle withAddress:address];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:XMLIOServiceDidGetThrottle
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                throttle, XMLIOThrottleKey,
                                                                [NSNumber numberWithUnsignedInteger:address], XMLIOThrottleAddress,
                                                                nil]];
}

- (void)XMLIOServiceHelperDidFinishLoading:(XMLIOServiceHelper *)helper {
    if ([self.delegate isKindOfClass:[RESPONDER class]] && ![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(XMLIOServiceHelperDidFinishLoading:) 
                               withObject:helper
                            waitUntilDone:NO];
        return;
    }
	[connections removeObjectForKey:[helper.request HTTPBody]];
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceDidFinishLoading:)]) {
		[self.delegate XMLIOServiceDidFinishLoading:self];
	}
	if (self.logTraffic) {
		NSLog(@"XMLIOService has just closed a connection. %lu connections remain open.", (unsigned long)[connections count]);
	}
}

#pragma mark - Net service delegate

// do not override superclass

#pragma mark - Object management

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super initWithNetService:service])) {
        serviceType = JMRIServiceXmlIO;
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
		monitoredItems = [[NSMutableSet alloc] initWithCapacity:0];
        throttles = [[NSMutableDictionary alloc] initWithCapacity:0];
		self.XMLIOPath = @"xmlio/";
        defaultMonitoringDelay = (self.useAttributeProtocol) ? 0 : 5;
        self.monitoringDelay = defaultMonitoringDelay;
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super initWithAddress:address withPort:port])) {
        serviceType = JMRIServiceXmlIO;
		connections = [[NSMutableDictionary alloc] initWithCapacity:0];
		monitoredItems = [[NSMutableSet alloc] initWithCapacity:0];
        throttles = [[NSMutableDictionary alloc] initWithCapacity:0];
		self.XMLIOPath = @"xmlio/";
        defaultMonitoringDelay = 5;
        self.monitoringDelay = defaultMonitoringDelay;
        [self list:JMRITypeMetadata];
	}
	return self;
}

- (void)dealloc {
	self.XMLIOPath = nil;
}

@end
