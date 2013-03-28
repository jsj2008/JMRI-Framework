//
//  JMRIService.m
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"
#import "JsonService.h"
#import "SimpleService.h"
#import "WebService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"
#import "JMRIConstants.h"
#import "JMRIItem+Internal.h"
#import "JMRILight.h"
#import "JMRIMemory.h"
#import "JMRIPower.h"
#import "JMRIReporter.h"
#import "JMRISensor.h"
#import "JMRISignalHead.h"
#import "JMRITurnout.h"

@interface JMRIService (Private) <JMRINetServiceDelegate, XMLIOServiceDelegate>

- (void)commonInit;

- (void)setStateInList:(NSDictionary *)list forItem:(XMLIOItem *)item;
- (void)setValueInList:(NSDictionary *)list forItem:(XMLIOItem *)item;

@end

@implementation JMRIService

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    if ((self = [super init])) {
        [self commonInit];
        if (ports[JMRIServiceJson]) {
            self.jsonService = [[JsonService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceJson] integerValue]];
            self.requiresJsonService = YES;
        } else {
            self.useJsonService = NO;
        }
        if ([ports valueForKey:JMRIServiceSimple]) {
            self.simpleService = [[SimpleService alloc] initWithName:name withAddress:address withPort:[[ports valueForKey:JMRIServiceSimple] integerValue]];
            self.requiresSimpleService = YES;
        } else {
            self.useSimpleService = NO;
        }
        if ([ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[WebService alloc] initWithName:name withAddress:address withPort:[[ports valueForKey:JMRIServiceWeb] integerValue]];
            self.requiresWebService = YES;
        } else {
            self.useWebService = NO;
        }
        if ([ports valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [[WiThrottleService alloc] initWithName:name withAddress:address withPort:[[ports valueForKey:JMRIServiceWiThrottle] integerValue]];
            self.requiresWiThrottleService = YES;
        } else {
            self.useWiThrottleService = NO;
        }
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports {
    return [self initWithName:nil withAddress:address withPorts:ports];
}

- (id)initWithServices:(NSDictionary *)services {
    if ((self = [super init])) {
        [self commonInit];
        if (services[JMRIServiceJson]) {
            self.jsonService = services[JMRIServiceJson];
            [self.jsonService startMonitoring];
            self.requiresJsonService = YES;
        } else {
            self.useJsonService = NO;
        }
        if ([services valueForKey:JMRIServiceSimple]) {
            self.simpleService = [services valueForKey:JMRIServiceSimple];
            [self.simpleService startMonitoring];
            self.requiresSimpleService = YES;
        } else {
            self.useSimpleService = NO;
        }
        if ([services valueForKey:JMRIServiceWeb]) {
            self.webService = [services valueForKey:JMRIServiceWeb];
            [self.webService startMonitoring];
            self.requiresWebService = YES;
        } else {
            self.useWebService = NO;
        }
        if ([services valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [services valueForKey:JMRIServiceWiThrottle];
            [self.wiThrottleService startMonitoring];
            self.requiresWiThrottleService = YES;
        } else {
            self.useWiThrottleService = NO;
        }
    }
    return self;
}

- (void)commonInit {
    power = [[JMRIPower alloc] initWithName:JMRITypePower withService:self];
    self.requiresJsonService = NO;
    self.requiresSimpleService = NO;
    self.requiresWebService = NO;
    self.requiresWiThrottleService = NO;
    self.requiresXmlIOService = NO;
    self.useJsonService = YES;
    self.useSimpleService = YES;
    self.useWebService = YES;
    self.useWiThrottleService = YES;
    self.useXmlIOService = NO;
}

#pragma mark - Object Handling

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRIService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
}

#pragma mark - Properties

- (NSArray *)addresses {
    if (self.hasJsonService) {
        return self.jsonService.addresses;
    } else if (self.hasSimpleService) {
        return self.simpleService.addresses;
    } else if (self.hasWebService) {
        return self.webService.addresses;
    } else if (self.hasWiThrottleService) {
        return self.wiThrottleService.addresses;
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
    return _name;
}

@synthesize delegate;

#pragma mark - Service properties

- (JsonService *)jsonService {
    return json;
}

- (void)setJsonService:(JsonService *)jsonService {
    if (json == jsonService) {
        return;
    }
    [json stopMonitoring];
    [json stop];
    json.delegate = nil;
    json = jsonService;
    json.delegate = self;
    [json startMonitoring];
    if (json) {
        domain = json.domain;
        hostName = json.hostName;
        _name = json.name;
    }
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
    simple.delegate = nil;
    simple = simpleService;
    simple.delegate = self;
    [simple startMonitoring];
    if (simple) {
        domain = simple.domain;
        hostName = simple.hostName;
        _name = simple.name;
    }
}

- (WebService *)webService {
    return web;
}

- (void)setWebService:(WebService *)webService {
    if (web == webService) {
        return;
    }
    [web stopMonitoring];
    [web stop];
    web.delegate = nil;
    web = webService;
    web.delegate = self;
    [web startMonitoring];
    if (web) {
        domain = web.domain;
        hostName = web.hostName;
        _name = web.name;
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
        _name = wiThrottle.name;
    }
}

- (XMLIOService *)xmlIOService {
    return xmlio;
}

- (void)setXmlIOService:(XMLIOService *)xmlIOService {
    if (xmlio == xmlIOService) {
        return;
    }
    [xmlio stopMonitoring];
    [xmlio stop];
    xmlio.delegate = nil;
    xmlio = xmlIOService;
    xmlio.delegate = self;
    [xmlio startMonitoring];
}

- (Boolean)hasJsonService {
    return (self.jsonService != nil);
}

- (Boolean)hasSimpleService {
    return (self.simpleService != nil);
}

- (Boolean)hasWebService {
    return (self.webService != nil);
}

- (Boolean)hasWiThrottleService {
    return (self.wiThrottleService != nil);
}

- (Boolean)hasXmlIOService {
    return (self.xmlIOService != nil);
}

- (NSString *)version {
    if (self.hasJsonService) {
        return self.jsonService.version;
    } else if (self.hasWebService) {
        return self.webService.version;
    } else if (self.hasXmlIOService) {
        return self.xmlIOService.version;
    } else if (self.hasSimpleService) {
        return self.simpleService.version;
    } else {
        return self.wiThrottleService.version;
    }
}

@synthesize requiresSimpleService = _requiresSimpleService;
@synthesize requiresWiThrottleService = _requiresWiThrottleService;
@synthesize requiresXmlIOService = _requiresXmlIOService;
@synthesize useSimpleService = _useSimpleService;
@synthesize useWiThrottleService = _useWiThrottleService;
@synthesize useXmlIOService = _useXmlIOService;

#pragma mark - JMRI Elements

@synthesize memories;
@synthesize panels;
@synthesize power;
@synthesize reporters;
@synthesize roster;
@synthesize routes;
@synthesize sensors;
@synthesize signalHeads;
@synthesize turnouts;

- (void)list:(NSString *)type {
    if (self.hasWebService && self.useWebService) {
        [self.webService list:type];
    } else if (self.hasJsonService && self.useJsonService) {
        [self.jsonService list:type];
    } else if (self.hasXmlIOService && self.useXmlIOService) {
        [self.xmlIOService list:type];
    }
}

- (void)monitor:(JMRIItem *)item {
    if (self.hasXmlIOService && self.useXmlIOService) {
        [self.xmlIOService startMonitoring:item.name ofType:item.type];
    }
}

- (void)stopMonitoring:(JMRIItem *)item {
    if (self.hasXmlIOService) {
        [self.xmlIOService stopMonitoring:item.name ofType:item.type];
    }
}

- (Boolean)isMonitoring:(JMRIItem *)item {
    if (self.hasXmlIOService) {
        return [self.xmlIOService isMonitoring:item.name ofType:item.type];
    }
    return NO;
}

- (void)stopMonitoringAllItems {
    if (self.hasXmlIOService) {
        [self.xmlIOService stopMonitoringAllItems];
    }
}

- (void)stop {
    [self.jsonService stop];
    [self.simpleService stop];
    [self.webService stop];
    [self.wiThrottleService stop];
    [self.xmlIOService stop];
}

#pragma mark - JMRINetService delegate

- (void)JMRINetService:(JMRINetService *)service didNotResolve:(NSDictionary *)errorDict {
    // JMRIService probably needs to handle this itself, but I'm not sure how
    if ([self.delegate respondsToSelector:@selector(JMRIService:didNotResolve:)]) {
        [self.delegate JMRIService:self didNotResolve:errorDict];
    }
}

- (void)JMRINetService:(JMRINetService *)service didFailWithError:(NSError *)error {
    if ([error.domain isEqualToString:JMRIErrorDomain]) {
        if (error.code == JMRIWebServiceJsonUnsupported) {
            // assume connection to JMRI 2.14.X server and that no other service is available
            if (service.service) {
                self.xmlIOService = [[XMLIOService alloc] initWithNetService:service.service];
            } else {
                self.xmlIOService = [[XMLIOService alloc] initWithName:service.name
                                                           withAddress:service.addresses[0]
                                                              withPort:service.port];
            }
            self.useXmlIOService = YES;
            self.requiresXmlIOService = self.requiresWebService;
            self.useWebService = NO;
            self.requiresWebService = NO;
            self.webService = nil;
            return; // don't pass on this error, we've handled it
        } else if (error.code == JMRIWebServiceJsonReadOnly) {
            if (!self.useJsonService && !self.useXmlIOService) {
                // use the Json service if the JMRI server supports it, otherwise switch to XmlIO
                if (service.service) {
                    self.xmlIOService = [[XMLIOService alloc] initWithNetService:service.service];
                } else {
                    self.xmlIOService = [[XMLIOService alloc] initWithName:service.name
                                                               withAddress:service.addresses[0]
                                                                  withPort:service.port];
                }
                self.useXmlIOService = YES;
                self.requiresXmlIOService = self.requiresWebService;
                self.useWebService = NO;
                self.requiresWebService = NO;
                self.webService = nil;
            }
            return; // don't pass on this error, we've handled it
        }
    }
    if ([self.delegate respondsToSelector:@selector(JMRIService:didFailWithError:)]) {
        [self.delegate JMRIService:self didFailWithError:error];
    }
}

- (void)JMRINetService:(JMRINetService *)service didGetLight:(NSString *)light withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.lights objectForKey:light]) {
        JMRILight *lightObj = [[JMRILight alloc] initWithName:light withService:self withProperties:properties];
        [self.lights setValue:lightObj forKey:light];
    }
    [((JMRILight *)[self.lights objectForKey:light]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetMemory:(NSString *)memory withValue:(NSString *)value withProperties:(NSDictionary *)properties {
    if (![self.memories objectForKey:memory]) {
        JMRIMemory *reporterObj = [[JMRIMemory alloc] initWithName:memory withService:self withProperties:properties];
        [self.memories setValue:reporterObj forKey:memory];
    }
    [((JMRIMemory *)[self.memories objectForKey:memory]) setValue:value updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetMetadata:(NSString *)metadata withValue:(NSString *)value {
    [self.metadata setValue:value forKey:metadata];
}

- (void)JMRINetService:(JMRINetService *)service didGetPowerState:(NSUInteger)state {
    [self.power setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetReporter:(NSString *)reporter withValue:(NSString *)value withProperties:(NSDictionary *)properties {
    if (![self.memories objectForKey:reporter]) {
        JMRIReporter *reporterObj = [[JMRIReporter alloc] initWithName:reporter withService:self withProperties:properties];
        [self.memories setValue:reporterObj forKey:reporter];
    }
    [((JMRIMemory *)[self.memories objectForKey:reporter]) setValue:value updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetSensor:(NSString *)sensor withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.sensors objectForKey:sensor]) {
        JMRISensor *turnoutObj = [[JMRISensor alloc] initWithName:sensor withService:self withProperties:properties];
        [self.sensors setValue:turnoutObj forKey:sensor];
    }
    [((JMRISensor *)[self.sensors objectForKey:sensor]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetSignalHead:(NSString *)signalHead withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.signalHeads objectForKey:signalHead]) {
        JMRISignalHead *signalHeadObj = [[JMRISignalHead alloc] initWithName:signalHead withService:self withProperties:properties];
        [self.signalHeads setValue:signalHeadObj forKey:signalHead];
    }
    [((JMRISignalHead *)[self.signalHeads objectForKey:signalHead]) setState:state updateService:NO];
}
- (void)JMRINetService:(JMRINetService *)service didGetTurnout:(NSString *)turnout withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.turnouts objectForKey:turnout]) {
        JMRITurnout *turnoutObj = [[JMRITurnout alloc] initWithName:turnout withService:self withProperties:properties];
        [self.turnouts setValue:turnoutObj forKey:turnout];
    }
    [((JMRITurnout *)[self.turnouts objectForKey:turnout]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didReceive:(NSString *)input {
    if (self.logNetworkActivity) {
        NSLog(@"%@ received %@", service.type, input);
    }
    if ([self.delegate respondsToSelector:@selector(JMRIService:didGetInput:)]) {
        [self.delegate JMRIService:self didGetInput:input];
    }
}

- (void)JMRINetService:(JMRINetService *)service didSend:(NSData *)data {
    if (self.logNetworkActivity) {
        NSLog(@"%@ sent %@", service.type, [NSString stringWithUTF8String:data.bytes]);
    }
}

- (void)JMRINetServiceDidOpenConnection:(JMRINetService *)service {
    if (self.logNetworkActivity) {
        NSLog(@"%@ opened connection", service.type);
    }
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidOpenConnection:)]) {
        [self.delegate JMRIServiceDidOpenConnection:self];
    }
}

- (void)JMRINetServiceDidStart:(JMRINetService *)service {
    NSLog(@"%@ started", service.type);
    if ([self.delegate respondsToSelector:@selector(JMRIService:didStart:)]) {
        [self.delegate JMRIService:self didStart:service];
    }
}

- (void)JMRINetServiceDidStop:(JMRINetService *)service {
    NSLog(@"%@ stopped", service.type);
    if ([self.delegate respondsToSelector:@selector(JMRIService:didStop:)]) {
        [self.delegate JMRIService:self didStop:service];
    }
}

- (void)JMRINetService:(JMRINetService *)service didWrite:(NSData *)data {
    if (self.logNetworkActivity) {
        NSLog(@"%@ wrote %@", service.type, [data description]);
    }
}

#pragma mark - XmlIO service delegate

- (void)XMLIOService:(XMLIOService *)service didListItems:(NSArray *)items ofType:(NSString *)type {
    if ([type isEqualToString:JMRITypeMemory]) {
        for (XMLIOItem *i in items) {
            [self setValueInList:self.memories forItem:i];
        }
    } else if ([type isEqualToString:JMRITypeMetadata]) {
        for (XMLIOItem *i in items) {
            [self setValueInList:self.metadata forItem:i];
        }
    } else if ([type isEqualToString:JMRITypePower]) {
        [self.power setState:[((XMLIOItem *)[items objectAtIndex:0]).value integerValue] updateService:NO];
    } else if ([type isEqualToString:JMRITypeRoute]) {
        for (XMLIOItem *i in items) {
            [self setStateInList:self.routes forItem:i];
        }
    } else if ([type isEqualToString:JMRITypeSensor]) {
        for (XMLIOItem *i in items) {
            [self setStateInList:self.sensors forItem:i];
        }
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        for (XMLIOItem *i in items) {
            [self setStateInList:self.turnouts forItem:i];
        }
    }
}

- (void)XMLIOService:(XMLIOService *)service didReadItem:(XMLIOItem *)item withName:(NSString *)aName ofType:(NSString *)type withValue:(NSString *)value {
    if ([type isEqualToString:JMRITypeMemory]) {
        [self setValueInList:self.memories forItem:item];
    } else if ([type isEqualToString:JMRITypeMetadata]) {
        [self setValueInList:self.metadata forItem:item];
    } else if ([type isEqualToString:JMRITypePower]) {
        [self.power setState:[value integerValue] updateService:NO];
    } else if ([type isEqualToString:JMRITypeRoute]) {
        [self setStateInList:self.routes forItem:item];
    } else if ([type isEqualToString:JMRITypeSensor]) {
        [self setStateInList:self.sensors forItem:item];
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        [self setStateInList:self.turnouts forItem:item];
    }
}

- (void)XMLIOService:(XMLIOService *)service didWriteItem:(XMLIOItem *)item withName:(NSString *)aName ofType:(NSString *)type withValue:(NSString *)value {
    [self XMLIOService:service didReadItem:item withName:aName ofType:type withValue:value];
}

- (void)XMLIOService:(XMLIOService *)service didGetThrottle:(XMLIOThrottle *)throttle withAddress:(NSUInteger)address {}
- (void)XMLIOService:(XMLIOService *)service didConnectWithRequest:(NSURLRequest *)request {
    if (self.logNetworkActivity) {
        NSLog(@"XMLIO%@ opened new connection. %lu connections are open.", service, (unsigned long)service.openConnections);
    }
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidOpenConnection:)]) {
        [self.delegate JMRIServiceDidOpenConnection:self];
    }
}

- (void)XMLIOServiceDidFinishLoading:(XMLIOService *)service { // need to log response being consumed by XMLIOServiceHelper
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidCloseConnection:)]) {
        [self.delegate JMRIServiceDidCloseConnection:self];
    }
}

- (void)setStateInList:(NSDictionary *)list forItem:(XMLIOItem *)item {
    if ([list objectForKey:item.name]) {
        ((JMRIItem *)[list objectForKey:item.name]).state = [item.value integerValue];
    } else {
        [list setValue:[item JMRIItemForService:self] forKey:item.name];
    }
}

- (void)setValueInList:(NSDictionary *)list forItem:(XMLIOItem *)item {
    if ([list objectForKey:item.name]) {
        ((JMRIItem *)[list objectForKey:item.name]).value = item.value;
    } else {
        [list setValue:[item JMRIItemForService:self] forKey:item.name];
    }
}

@end