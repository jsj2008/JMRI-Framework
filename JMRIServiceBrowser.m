/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 7/5/2011.
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
		self.browser = [[[NSNetServiceBrowser alloc] init] autorelease];
        self.browser.delegate = self;
		self.services = [NSMutableArray arrayWithCapacity:0];
		_searching = NO;
	}
	return self;
}

- (void)dealloc {
	self.services = nil;
	self.browser = nil;
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
    if (index != NSNotFound) {
        service = [self.services objectAtIndex:index];
        [self.services removeObjectAtIndex:index];
    } else {
        service = [[[JMRINetService alloc] initWithNetService:aNetService] autorelease];
    }
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