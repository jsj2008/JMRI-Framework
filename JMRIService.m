//
//  JMRIService.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"
#import "JMRIConstants.h"
#import "JMRIItem+Internal.h"
#import "JMRIPower.h"
#import "JMRITurnout.h"

@interface JMRIService (Private)

- (void)commonInit;

@end

@implementation JMRIService

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    if (([super init] != nil)) {
        [self commonInit];
        if ([ports valueForKey:JMRIServiceSimple]) {
            self.simpleService = [[SimpleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceSimple] integerValue]];
            self.requiresSimpleService = YES;
        } else {
            self.useSimpleService = NO;
        }
        if ([ports valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [[WiThrottleService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceWiThrottle] integerValue]];
            self.requiresWiThrottleService = YES;
        } else {
            self.useWiThrottleService = NO;
        }
        if ([ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[XMLIOService alloc] initWithAddress:address withPort:[[ports valueForKey:JMRIServiceWeb] integerValue]];
            self.requiresXmlIOService = YES;
        } else {
            self.useXmlIOService = NO;
        }
    }
    return self;
}

- (id)initWithWebServices:(NSDictionary *)services {
    if (([super init] != nil)) {
        [self commonInit];
        if ([services valueForKey:JMRIServiceSimple]) {
            self.simpleService = [services valueForKey:JMRIServiceSimple];
            [self.simpleService startMonitoring];
            self.requiresSimpleService = YES;
        } else {
            self.useSimpleService = NO;
        }
        if ([services valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [services valueForKey:JMRIServiceWiThrottle];
            [self.wiThrottleService startMonitoring];
            self.requiresWiThrottleService = YES;
        } else {
            self.useWiThrottleService = NO;
        }
        if ([services valueForKey:JMRIServiceWeb]) {
            self.webService = [services valueForKey:JMRIServiceWeb];
            [self.webService startMonitoring];
            self.requiresXmlIOService = YES;
        } else {
            self.useXmlIOService = NO;
        }
    }
    return self;
}

- (void)commonInit {
    power = [[JMRIPower alloc] initWithName:JMRITypePower withService:self];
    self.requiresSimpleService = NO;
    self.requiresWiThrottleService = NO;
    self.requiresXmlIOService = NO;
    self.useSimpleService = YES;
    self.useWiThrottleService = YES;
    self.useXmlIOService = YES;
}

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRIService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
}

#pragma mark - Properties

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

@synthesize delegate;

#pragma mark - Service properties

- (SimpleService *)simpleService {
    return simple;
}

- (void)setSimpleService:(SimpleService *)simpleService {
    if (simple == simpleService) {
        return;
    }
    [simple stopMonitoring];
    [simple stop];
    simple.delegate = nil;
    simple = simpleService;
    simple.delegate = self;
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
    xmlio.delegate = nil;
    xmlio = webService;
    xmlio.delegate = self;
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
    wiThrottle.delegate = nil;
    wiThrottle = wiThrottleService;
    wiThrottle.delegate = self;
    [wiThrottle startMonitoring];
    if (wiThrottle) {
        domain = wiThrottle.domain;
        hostName = wiThrottle.hostName;
        name = wiThrottle.name;
    }
}


- (Boolean)hasSimpleService {
    return (self.simpleService != nil);
}

- (Boolean)hasWiThrottleService {
    return (self.wiThrottleService != nil);
}

- (Boolean)hasWebService {
    return (self.webService != nil);
}

@synthesize requiresSimpleService = _requiresSimpleService;
@synthesize requiresWiThrottleService = _requiresWiThrottleService;
@synthesize requiresXmlIOService = _requiresXmlIOService;
@synthesize useSimpleService = _useSimpleService;
@synthesize useWiThrottleService = _useWiThrottleService;
@synthesize useXmlIOService = _useXmlIOService;

#pragma mark - JMRI Elements

@synthesize memoryVariables;
@synthesize panels;
@synthesize power;
@synthesize reporters;
@synthesize roster;
@synthesize routes;
@synthesize sensors;
@synthesize turnouts;

- (void)monitor:(JMRIItem *)item {
    if (self.hasWebService && self.useXmlIOService) {
        [self.webService startMonitoring:item.name ofType:item.type];
    }
}

- (void)stopMonitoring:(JMRIItem *)item {
    if (self.hasWebService) {
        [self.webService stopMonitoring:item.name ofType:item.type];
    }
}

- (Boolean)isMonitoring:(JMRIItem *)item {
    if (self.hasWebService) {
        return [self.webService isMonitoring:item.name ofType:item.type];
    }
    return NO;
}

#pragma mark - JMRINetService delegate

- (void)JMRINetService:(JMRINetService *)service didNotResolve:(NSDictionary *)errorDict {
    // JMRIService probably needs to handle this itself, but I'm not sure how
    if ([self.delegate respondsToSelector:@selector(JMRIService:didNotResolve:)]) {
        [self.delegate JMRIService:self didNotResolve:errorDict];
    }
}

- (void)JMRINetService:(JMRINetService *)service didGetPowerState:(NSUInteger)state {
    [self.power setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetTurnout:(NSString *)turnout withState:(NSUInteger)state {
    if (![self.turnouts objectForKey:turnout]) {
        JMRITurnout *turnoutObj = [[JMRITurnout alloc] initWithName:turnout withService:self];
        [self.turnouts setValue:turnoutObj forKey:turnout];
    }
    [((JMRITurnout *)[self.turnouts objectForKey:turnout]) setState:state updateService:NO];
}

#pragma mark - Simple service delegate

- (void)simpleService:(SimpleService *)service didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(JMRIService:didFailWithError:)]) {
        [self.delegate JMRIService:self didFailWithError:error];
    }
}

- (void)simpleService:(SimpleService *)service didGetInput:(NSString *)input {
    if ([self.delegate respondsToSelector:@selector(JMRIService:didGetInput:)]) {
        [self.delegate JMRIService:self didGetInput:input];
    }
}

- (void)simpleServiceDidOpenConnection:(SimpleService *)service {
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidOpenConnection:)]) {
        [self.delegate JMRIServiceDidOpenConnection:self];
    }
}

#pragma mark - Web service delegate

- (void)XMLIOService:(XMLIOService *)service didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(JMRIService:didFailWithError:)]) {
        [self.delegate JMRIService:self didFailWithError:error];
    }
}

- (void)XMLIOService:(XMLIOService *)service didListItems:(NSArray *)items ofType:(NSString *)type {
    if ([type isEqualToString:JMRITypePower]) {
        [self.power setState:[((XMLIOItem *)[items objectAtIndex:0]).value integerValue] updateService:NO];
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        for (XMLIOItem *i in items) {
            if ([self.turnouts objectForKey:i.name]) {
                ((JMRITurnout *)[self.turnouts objectForKey:i.name]).state = [i.value integerValue];
            } else {
                [self.turnouts setValue:[i JMRIItemForService:self] forKey:i.name];
            }
        }
    }
}

- (void)XMLIOService:(XMLIOService *)service didReadItem:(XMLIOItem *)item withName:(NSString *)aName ofType:(NSString *)type withValue:(NSString *)value {
    if ([type isEqualToString:JMRITypePower]) {
        [self.power setState:[item.value integerValue] updateService:NO];
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        if ([self.turnouts objectForKey:aName]) {
            ((JMRITurnout *)[self.turnouts objectForKey:aName]).state = [item.value integerValue];
        } else {
            [self.turnouts setValue:[item JMRIItemForService:self] forKey:aName];
        }
    }
}

- (void)XMLIOService:(XMLIOService *)service didWriteItem:(XMLIOItem *)item withName:(NSString *)aName ofType:(NSString *)type withValue:(NSString *)value {
    [self XMLIOService:service didReadItem:item withName:aName ofType:type withValue:value];
}

- (void)XMLIOService:(XMLIOService *)service didGetThrottle:(XMLIOThrottle *)throttle withAddress:(NSUInteger)address {}
- (void)XMLIOService:(XMLIOService *)service didConnectWithRequest:(NSURLRequest *)request {}
- (void)XMLIOServiceDidFinishLoading:(XMLIOService *)service {}

@end