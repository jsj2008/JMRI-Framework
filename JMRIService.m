//
//  JMRIService.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"

@implementation JMRIService

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    if (([super init] != nil)) {
        if ([ports valueForKey:JMRIServiceSimple]) {
            self.simpleService = [[SimpleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceSimple] integerValue]];
        }
        if ([ports valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [[WiThrottleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceWiThrottle] integerValue]];
        }
        if ([ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[XMLIOService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceWeb] integerValue]];
        }
    }
    return self;
}

- (id)initWithWebServices:(NSDictionary *)services {
    if (([super init] != nil)) {
        self.simpleService = [services valueForKey:JMRIServiceSimple];
        [self.simpleService startMonitoring];
        self.wiThrottleService = [services valueForKey:JMRIServiceWiThrottle];
        [self.wiThrottleService startMonitoring];
        self.webService = [services valueForKey:JMRIServiceWeb];
        [self.webService startMonitoring];
    }
    return self;
}

#pragma - Properties

- (Boolean)hasSimpleService {
    return (self.simpleService != nil);
}

- (Boolean)hasWiThrottleService {
    return (self.wiThrottleService != nil);
}

- (Boolean)hasWebService {
    return (self.webService != nil);
}

- (NSArray *)addresses {
    if (self.hasSimpleService) {
        return self.simpleService.addresses;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.addresses;
    } else if (self.hasWebService) {
        return self.webService.addresses;
    }
    return nil;
}

- (NSString *)domain {
    if (self.hasSimpleService) {
        return self.simpleService.domain;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.domain;
    } else if (self.hasWebService) {
        return self.webService.domain;
    }
    return nil;
}

- (NSString *)hostName {
    if (self.hasSimpleService) {
        return self.simpleService.hostName;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.hostName;
    } else if (self.hasWebService) {
        return self.webService.hostName;
    }
    return nil;
}

- (NSString *)name {
    if (self.hasSimpleService) {
        return self.simpleService.name;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.name;
    } else if (self.hasWebService) {
        return self.webService.name;
    }
    return nil;
}

- (SimpleService *)simpleService {
    return simple;
}

- (void)setSimpleService:(SimpleService *)simpleService {
    if (simple == simpleService) {
        return;
    }
    [simple stopMonitoring];
    [simple stop];
    simple = simpleService;
    [simple startMonitoring];
}

- (XMLIOService *)webService {
    return xmlio;
}

- (void)setWebService:(XMLIOService *)webService {
    if (xmlio == webService) {
        return;
    }
    [xmlio stopMonitoring];
    [xmlio stop];
    xmlio = webService;
    [xmlio startMonitoring];
}

- (WiThrottleService *)wiThrottleService {
    return wiThrottle;
}

- (void)setWiThrottleService:(WiThrottleService *)wiThrottleService {
    if (wiThrottle == wiThrottleService) {
        return;
    }
    [wiThrottle stopMonitoring];
    [wiThrottle stop];
    wiThrottle = wiThrottleService;
    [wiThrottle startMonitoring];
}

@end
