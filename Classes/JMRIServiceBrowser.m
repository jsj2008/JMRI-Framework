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
        wiThrottleBrowser = [[[WiThrottleServiceBrowser alloc] init] autorelease];
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
    JMRIService *service;
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceSimple]) {
            service.simpleService = (SimpleService *)aNetService;
        } else if ([aNetService.type isEqualToString:JMRIServiceWiThrottle]) {
            service.wiThrottleService = (WiThrottleService *)aNetService;
        } else {
            service.xmlIOService = (XMLIOService *)aNetService;
        }
        if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
            [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
        }
    } else {
        service = [[JMRIService alloc] initWithWebServices:[NSMutableDictionary dictionaryWithObject:aNetService forKey:aNetService.type]];
        [self.services addObject:service];
        if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
            [delegate JMRIServiceBrowser:self didFindService:service moreComing:searching];
        }
    }
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didRemoveService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        JMRIService *service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceSimple]) {
            service.simpleService = nil;
        } else if ([aNetService.type isEqualToString:JMRIServiceWiThrottle]) {
            service.wiThrottleService = nil;
        } else {
            service.xmlIOService = nil;
        }
        if (service.hasSimpleService || service.hasWiThrottleService || service.hasXmlIOService) {
            if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
                [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
            }
        } else {
            [self.services removeObject:service];
            if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didRemoveService:moreComing:)]) {
                [delegate JMRIServiceBrowser:self didRemoveService:service moreComing:searching];
            }
        }
    }
}

@end
