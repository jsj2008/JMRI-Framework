//
//  JMRIServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 8/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIServiceBrowser.h"

@implementation JMRIServiceBrowser

@synthesize delegate;
@synthesize searching;
@synthesize services;

- (id)init {
	if ((self = [super init])) {
		//self.browser = [[[NSNetServiceBrowser alloc] init] autorelease];
        //self.browser.delegate = self;
        simpleBrowser = [[[SimpleServiceBrowser alloc] init] autorelease];
        simpleBrowser.delegate = self;
        wiThrottleBrowser = [[[JMRIWiThrottleServiceBrowser alloc] init] autorelease];
        wiThrottleBrowser.delegate = self;
        xmlIOBrowser = [[[XMLIOServiceBrowser alloc] init] autorelease];
        xmlIOBrowser.delegate = self;
		self.services = [NSMutableArray arrayWithCapacity:0];
		searching = NO;
	}
	return self;
}

- (void)dealloc {
	self.services = nil;
	[super dealloc];
}

#pragma mark - Service browser methods

- (void)searchForServices {
    [simpleBrowser searchForServices];
    [wiThrottleBrowser searchForServices];
    [xmlIOBrowser searchForServices];
}

- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    [self.services addObject:[[JMRIService alloc] initWithAddress:address withPorts:ports]];
}

- (void)stop {
    [simpleBrowser stop];
    [wiThrottleBrowser stop];
    [xmlIOBrowser stop];
}

#pragma mark - Utility methods

- (BOOL)containsService:(JMRIService *)service {
    return ([self indexOfServiceWithName:[service name]] != NSNotFound);
}

- (void)sortServices {
    [self.services sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}

- (NSUInteger)indexOfServiceWithName:(NSString *)name {
    return [self.services indexOfObjectWithName:name];
}

- (JMRIService *)serviceWithName:(NSString *)name {
    return [self.services objectWithName:name];
}

#pragma mark - JMRI net service browser delegate

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
    searching = NO;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didNotSearch:)]) {
        [delegate JMRIServiceBrowser:self didNotSearch:errorDict];
    }
}

- (void)JMRINetServiceBrowserWillSearch:(JMRINetServiceBrowser *)browser {
    searching = YES;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserWillSearch:)]) {
        [delegate JMRIServiceBrowserWillSearch:self];
    }
}

- (void)JMRINetServiceBrowserDidStopSearch:(JMRINetServiceBrowser *)browser {
    searching = NO;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserDidStopSearch:)]) {
        [delegate JMRIServiceBrowserDidStopSearch:self];
    }
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didFindService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    // need to add aNetService to an existing JMRIService or create a new JMRIService
    // then trigger JMRIServiceBrowser:didChangeService: in the delegate
    // if a new service is created, trigger JMRIServiceBrowser:didFindService: in the delegate
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didRemoveService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    // need to remove aNetService from an existing JMRIService
    // and then trigger JMRIServiceBrowser:didChangeService: in the delegate
    // if aNetService was not in a JMRIService, no notification is passed
    // if the existing JMRIService has no services, remove it and trigger JMRIServiceBrowser:didRemoveService:
}

@end
