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
        simpleBrowser = [[SimpleServiceBrowser alloc] init];
        simpleBrowser.delegate = self;
        wiThrottleBrowser = [[WiThrottleServiceBrowser alloc] init];
        wiThrottleBrowser.delegate = self;
        webBrowser = [[XMLIOServiceBrowser alloc] init];
        webBrowser.delegate = self;
		self.services = [NSMutableArray arrayWithCapacity:0];
		searching = NO;
	}
	return self;
}


#pragma mark - Service browser methods

- (void)searchForServices {
    [simpleBrowser searchForServices];
    [wiThrottleBrowser searchForServices];
    [webBrowser searchForServices];
}

- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    [self.services addObject:[[JMRIService alloc] initWithAddress:address withPorts:ports]];
}

- (void)stop {
    [simpleBrowser stop];
    [wiThrottleBrowser stop];
    [webBrowser stop];
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
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        JMRIService *service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceSimple]) {
            service.simpleService = (SimpleService *)aNetService;
        } else if ([aNetService.type isEqualToString:JMRIServiceWiThrottle]) {
            service.wiThrottleService = (WiThrottleService *)aNetService;
        } else {
            service.webService = (XMLIOService *)aNetService;
        }
        if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
            [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
        }
    } else {
        JMRIService *service = [[JMRIService alloc] initWithWebServices:[NSMutableDictionary dictionaryWithObject:aNetService forKey:aNetService.type]];
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
            service.webService = nil;
        }
        if (service.hasSimpleService || service.hasWiThrottleService || service.hasWebService) {
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
