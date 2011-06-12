//
//  JMRIServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 7/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIServiceBrowser.h"
#import "JMRINetService.h"

NSString *const JMRIServiceTypeXMLIO = @"_http._tcp.";
NSString *const JMRIServiceTypeWiThrottle = @"_withrottle._tcp.";

@implementation JMRIServiceBrowser

@synthesize browser = _browser;
@synthesize delegate = _delegate;
@synthesize searching = _searching;
@synthesize services = _services;

- (id)init {
	if ((self = [super init])) {
		self.browser = [[NSNetServiceBrowser alloc] init];
		[self.browser setDelegate:self];
		self.services = [NSMutableArray arrayWithCapacity:0];
		_searching = NO;
	}
	return self;
}

- (void)dealloc {
	[self.services release];
	[self.browser release];
	[super dealloc];
}

#pragma mark -
#pragma mark Service browser methods

- (void)searchForServices {
	[self doesNotRecognizeSelector:_cmd];
	// sample implementation:
	//[self.browser searchForServicesOfType:JMRIServiceXMLIO inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)stop {
	[self.browser stop];
}

#pragma mark -
#pragma mark Utility methods

- (BOOL)containsService:(NSNetService *)service {
	return ([self indexOfServiceWithName:[service name]] != NSNotFound);
}

- (void)sortServices {
	[self.services sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}

- (NSUInteger)indexOfServiceWithName:(NSString *)name {
//	return [self.services indexOfObjectPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
//		return [[obj name] isEqualToString:name];
//	}];
	return [self.services indexOfObjectWithName:name];
}

- (JMRINetService *)serviceWithName:(NSString *)name {
	return [self.services objectWithName:name];
}

#pragma mark -
#pragma mark Net Service Browser delegate

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
	_searching = YES;
	if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowserWillSearch:)]) {
		[self.delegate JMRIServiceBrowserWillSearch:self];
	}
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
	_searching = NO;
	if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowserDidStopSearch:)]) {
		[self.delegate JMRIServiceBrowserDidStopSearch:self];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
	_searching = NO;
	if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didNotSearch:)]) {
		[self.delegate JMRIServiceBrowser:self didNotSearch:errorDict];
	}
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	_searching = moreComing;
	[aNetService retain];
	[aNetService setDelegate:self];
	[aNetService resolveWithTimeout:10];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	JMRINetService *service;
	NSInteger index;
	index = [self indexOfServiceWithName:[aNetService name]];
	service = [self.services objectAtIndex:index];
	[self.services removeObjectAtIndex:index];
	if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didRemoveService:moreComing:)]) {
		[self.delegate JMRIServiceBrowser:self didRemoveService:service moreComing:moreComing];
	}
}

#pragma mark -
#pragma mark Net service delegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	[self doesNotRecognizeSelector:_cmd];
	// sample implementation:
	//JMRINetService *service;
	//service = [[[JMRINetService alloc] initWithNetService:aNetService] autorelease];
	//[self.services addObject:service];
	//if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
	//	[self.delegate JMRIServiceBrowser:self didFindService:service moreComing:moreComing];
	//}	
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"JMRIServiceBrowser error resolving new service!\n%@", errorDict);
}

@end