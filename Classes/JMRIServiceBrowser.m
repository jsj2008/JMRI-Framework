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
#import "JMRIService+Internal.h"
#import "JsonServiceBrowser.h"
#import "WebServiceBrowser.h"
#import "WiThrottleServiceBrowser.h"

@interface JMRIServiceBrowser (Private) <JMRINetServiceBrowserDelegate>

@end

@implementation JMRIServiceBrowser

@synthesize delegate;
@synthesize searching;
@synthesize services = _services;
@synthesize requiredServices = _requiredServices;
@synthesize logEvents;

- (id)init {
    if ((self = [super init])) {
        jsonBrowser = [[JsonServiceBrowser alloc] init];
        jsonBrowser.delegate = self;
        webBrowser = [[WebServiceBrowser alloc] init];
        webBrowser.delegate = self;
        // uncomment following two lines when re-enabling the WiThrottle service
        //wiThrottleBrowser = [[WiThrottleServiceBrowser alloc] init];
        //wiThrottleBrowser.delegate = self;
        _services = [NSMutableArray arrayWithCapacity:0];
        _requiredServices = nil;
        searching = NO;
        logEvents = NO;
    }
    return self;
}

- (id)initForServices:(NSSet *)services {
    NSMutableSet *sanitize = [[NSMutableSet alloc] initWithSet:services];
    // remove or comment the following line when re-enabling the WiThrottle service
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

- (void)logEvent:(NSString *)format, ... {
    if (self.logEvents) {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:[@"JMRI Browser: " stringByAppendingString:format] arguments:args];
        va_end(args);
        NSLog(@"%@", message);
    }
}

#pragma mark - JMRI net service browser delegate

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict {
    [self logEvent:@"Did not search for %@s", browser.type];
    searching = NO;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didNotSearch:forType:)]) {
        [delegate JMRIServiceBrowser:self didNotSearch:errorDict forType:browser.type];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationBrowserDidNotSearch
                                                        object:self
                                                      userInfo:errorDict];
}

- (void)JMRINetServiceBrowserWillSearch:(JMRINetServiceBrowser *)browser {
    [self logEvent:@"Will search for %@s", browser.type];
    searching = YES;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserWillSearch:forType:)]) {
        [delegate JMRIServiceBrowserWillSearch:self forType:browser.type];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationBrowserWillSearch
                                                        object:self
                                                      userInfo:nil];
}

- (void)JMRINetServiceBrowserDidStopSearch:(JMRINetServiceBrowser *)browser {
    [self logEvent:@"Stopped searching for %@s", browser.type];
    searching = NO;
    if ([delegate respondsToSelector:@selector(JMRIServiceBrowserDidStopSearch:forType:)]) {
        [delegate JMRIServiceBrowserDidStopSearch:self forType:browser.type];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationBrowserDidStopSearch
                                                        object:self
                                                      userInfo:@{JMRIType: browser.type}];
}

- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didFindService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing {
    searching = moreComing;
    Boolean notify = YES;
    JMRIService *service;
    if ([self indexOfServiceWithName:aNetService.name] != NSNotFound) {
        service = [self serviceWithName:aNetService.name];
        if ([aNetService.type isEqualToString:JMRIServiceJson]) {
            service.jsonService = (JsonService *)aNetService;
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
        service = [[JMRIService alloc] initWithServices:[NSSet setWithObject:aNetService]];
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
        [self logEvent:@"Removing %@ from \"%@\"", aNetService.type, service.name];
        if ([aNetService.type isEqualToString:JMRIServiceJson]) {
            service.jsonService = nil;
        } else if ([aNetService.type isEqualToString:JMRIServiceWeb]) {
            service.webService = nil;
            if (service.jsonService && service.jsonService.webSocketURL) {
                service.jsonService = nil;
            }
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
        if (retain && (service.hasJsonService || service.hasWebService || service.hasWiThrottleService)) {
            [self logEvent:@"Retaining service \"%@\"", service.name];
            if ([delegate respondsToSelector:@selector(JMRIServiceBrowser:didChangeService:moreComing:)]) {
                [delegate JMRIServiceBrowser:self didChangeService:service moreComing:searching];
            }
        } else {
            [self logEvent:@"No longer retaining service \"%@\"", service.name];
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
