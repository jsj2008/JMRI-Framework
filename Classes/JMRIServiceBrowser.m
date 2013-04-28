//
//  JMRIServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 8/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIServiceBrowser.h"
#import "JMRIConstants.h"
#import "JMRIService.h"
#import "JsonServiceBrowser.h"
#import "SimpleServiceBrowser.h"
#import "WebServiceBrowser.h"
#import "WiThrottleServiceBrowser.h"

@interface JMRIServiceBrowser (Private) <JMRINetServiceBrowserDelegate>

@end

@implementation JMRIServiceBrowser

@synthesize delegate;
@synthesize searching;
@synthesize services = _services;
@synthesize requiredServices = _requiredServices;

- (id)init {
    if ((self = [super init])) {
        jsonBrowser = [[JsonServiceBrowser alloc] init];
        jsonBrowser.delegate = self;
        simpleBrowser = [[SimpleServiceBrowser alloc] init];
        simpleBrowser.delegate = self;
        webBrowser = [[WebServiceBrowser alloc] init];
        webBrowser.delegate = self;
        // uncomment following two lines when re-enabling the WiThrottle service
        //wiThrottleBrowser = [[WiThrottleServiceBrowser alloc] init];
        //wiThrottleBrowser.delegate = self;
        self.services = [NSMutableArray arrayWithCapacity:0];
        _requiredServices = nil;
        searching = NO;
    }
    return self;
}

- (id)initForServices:(NSSet *)services {
    // remove or comment following three lines when re-enabling the WiThrottle service
    NSMutableSet *sanitize = [[NSMutableSet alloc] initWithSet:services];
    [sanitize removeObject:JMRIServiceWiThrottle];
    services = [[NSSet alloc] initWithSet:sanitize];
	if ((self = [self init])) {
        _requiredServices = services;
    }
    return self;
}

#pragma mark - Service browser methods

- (void)searchForServices {
    [jsonBrowser searchForServices];
    [simpleBrowser searchForServices];
    [wiThrottleBrowser searchForServices];
    [webBrowser searchForServices];
}

- (void)addServiceWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    [self.services addObject:[[JMRIService alloc] initWithName:name withAddress:address withPorts:ports]];
}

- (void)addServiceWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    [self.services addObject:[[JMRIService alloc] initWithAddress:address withPorts:ports]];
}

- (void)removeServiceWithName:(NSString *)name {
    JMRIService *service = [self.services objectWithName:name];
    [self.services removeObjectIdenticalTo:service];
}

- (void)stop {
    [jsonBrowser stop];
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
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didNotSearch:forType:)]) {
        [delegate JMRIServiceBrowser:self didNotSearch:errorDict forType:browser.type];
    }
}

- (void)JMRINetServiceBrowserWillSearch:(JMRINetServiceBrowser *)browser {
    searching = YES;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserWillSearch:forType:)]) {
        [delegate JMRIServiceBrowserWillSearch:self forType:browser.type];
    }
}

- (void)JMRINetServiceBrowserDidStopSearch:(JMRINetServiceBrowser *)browser {
    searching = NO;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserDidStopSearch:forType:)]) {
        [delegate JMRIServiceBrowserDidStopSearch:self forType:browser.type];
    }
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didFindService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    Boolean notify = YES;
    JMRIService *service;
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceJson]) {
            service.jsonService = (JsonService *)aNetService;
        } else if ([aNetService.type isEqualToString:JMRIServiceSimple]) {
            service.simpleService = (SimpleService *)aNetService;
        } else if ([aNetService.type isEqualToString:JMRIServiceWeb]) {
            service.webService = (WebService *)aNetService;
        } else {
            service.wiThrottleService = (WiThrottleService *)aNetService;
        }
        if (self.requiredServices) {
            for (NSString *required in self.requiredServices) {
                if (![service valueForKey:required]) {
                    notify = NO;
                    break;
                }
            }
        }
        if (notify && [delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
            [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
        }
    } else {
        service = [[JMRIService alloc] initWithServices:[NSMutableDictionary dictionaryWithObject:aNetService forKey:aNetService.type]];
        [self.services addObject:service];
        if (self.requiredServices) {
            for (NSString *required in self.requiredServices) {
                if (![service valueForKey:required]) {
                    notify = NO;
                    break;
                }
            }
        }
        if (notify && [delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
            [delegate JMRIServiceBrowser:self didFindService:service moreComing:searching];
        }
    }
    if (notify) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationBonjourServiceAdded
                                                            object:self
                                                          userInfo:@{
                                           JMRIAddedBonjourService: aNetService,
                                                JMRIChangedService: service}];
    }
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didRemoveService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        JMRIService *service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceJson]) {
            service.jsonService = nil;
        } else if ([aNetService.type isEqualToString:JMRIServiceSimple]) {
            service.simpleService = nil;
        } else if ([aNetService.type isEqualToString:JMRIServiceWeb]) {
            service.webService = nil;
            service.xmlIOService = nil;
        } else {
            service.wiThrottleService = nil;
        }
        Boolean retain = (!self.requiredServices);
        for (NSString *required in self.requiredServices) {
            if (![service valueForKey:required]) {
                retain = NO;
                break;
            }
        }
        if (retain && (service.hasJsonService || service.hasSimpleService || service.hasWebService || service.hasWiThrottleService || service.hasXmlIOService)) {
            if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
                [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
            }
        } else {
            [self.services removeObject:service];
            if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didRemoveService:moreComing:)]) {
                [delegate JMRIServiceBrowser:self didRemoveService:service moreComing:searching];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationBonjourServiceRemoved
                                                            object:self
                                                          userInfo:@{
                                         JMRIRemovedBonjourService: aNetService,
                                                JMRIChangedService: service}];
    }
}

@end
