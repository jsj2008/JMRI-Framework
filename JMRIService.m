//
//  JMRIService.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"

@implementation JMRIService

@synthesize simpleService = simple;
@synthesize wiThrottleService = wiThrottle;
@synthesize xmlIOService = xmlio;

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    if (([super init] != nil)) {
        if ([ports valueForKey:JMRIServiceSimple]) {
            self.simpleService = [[[SimpleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceSimple] integerValue]] autorelease];
        }
        if ([ports valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [[[WiThrottleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceWiThrottle] integerValue]] autorelease];
        }
        if ([ports valueForKey:JMRIServiceXmlIO]) {
            self.xmlIOService = [[[XMLIOService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceXmlIO] integerValue]] autorelease];
        }
    }
    return self;
}

- (id)initWithWebServices:(NSDictionary *)services {
    if (([super init] != nil)) {
        self.simpleService = [services valueForKey:JMRIServiceSimple];
        self.wiThrottleService = [services valueForKey:JMRIServiceWiThrottle];
        self.xmlIOService = [services valueForKey:JMRIServiceXmlIO];
    }
    return self;
}

- (Boolean)hasSimpleService {
    return (self.simpleService != nil);
}

- (Boolean)hasWiThrottleService {
    return (self.wiThrottleService != nil);
}

- (Boolean)hasXmlIOService {
    return (self.xmlIOService != nil);
}

- (NSArray *)addresses {
    if (self.hasSimpleService) {
        return self.simpleService.addresses;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.addresses;
    } else if (self.hasXmlIOService) {
        return self.xmlIOService.addresses;
    }
    return nil;
}

- (NSString *)domain {
    if (self.hasSimpleService) {
        return self.simpleService.domain;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.domain;
    } else if (self.hasXmlIOService) {
        return self.xmlIOService.domain;
    }
    return nil;
}

- (NSString *)hostName {
    if (self.hasSimpleService) {
        return self.simpleService.hostName;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.hostName;
    } else if (self.hasXmlIOService) {
        return self.xmlIOService.hostName;
    }
    return nil;
}

- (NSString *)name {
    if (self.hasSimpleService) {
        return self.simpleService.name;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.name;
    } else if (self.hasXmlIOService) {
        return self.xmlIOService.name;
    }
    return nil;
}

@end
