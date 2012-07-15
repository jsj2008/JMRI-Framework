//
//  JMRIService.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"
#import "JMRIConstants.h"

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

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRIService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
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
    return domain;
}

- (NSString *)hostName {
    return hostName;
}

- (NSString *)name {
    return name;
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
    if (simple) {
        domain = simple.domain;
        hostName = simple.hostName;
        name = simple.name;
    }
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
    if (xmlio) {
        domain = xmlio.domain;
        hostName = xmlio.hostName;
        name = xmlio.name;
    }
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
    if (wiThrottle) {
        domain = wiThrottle.domain;
        hostName = wiThrottle.hostName;
        name = wiThrottle.name;
    }
}

@end
