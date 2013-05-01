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
#import "JMRIMetadata.h"
#import "JMRIPower.h"
#import "JMRIReporter.h"
#import "JMRISensor.h"
#import "JMRISignalHead.h"
#import "JMRITurnout.h"

@interface JMRIService (Private) <JMRINetServiceDelegate, XMLIOServiceDelegate>

- (void)commonInit;

- (void)itemAddedToList:(NSNotification *)notification;

- (void)queryPower;

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
            self.simpleService = [[SimpleService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceSimple] integerValue]];
            self.requiresSimpleService = YES;
        } else {
            self.useSimpleService = NO;
        }
        if ([ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[WebService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceWeb] integerValue]];
            self.requiresWebService = YES;
        } else {
            self.useWebService = NO;
        }
        if ([ports valueForKey:JMRIServiceXmlIO] && ![ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[WebService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceXmlIO] integerValue]];
            self.requiresWebService = YES;
        } else {
            self.useWebService = NO;
        }
        if ([ports valueForKey:JMRIServiceWiThrottle]) {
            self.wiThrottleService = [[WiThrottleService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceWiThrottle] integerValue]];
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

- (id)initWithServices:(NSSet *)services {
    if ((self = [super init])) {
        [self commonInit];
        for (JMRINetService *service in services) {
            if ([service.type isEqualToString:JMRIServiceJson]) {
                self.jsonService = (JsonService *)service;
                [self.jsonService startMonitoring];
                self.requiresJsonService = YES;
            } else {
                self.useJsonService = NO;
            }
            if ([service.type isEqualToString:JMRIServiceSimple]) {
                self.simpleService = (SimpleService *)service;
                [self.simpleService startMonitoring];
                self.requiresSimpleService = YES;
            } else {
                self.useSimpleService = NO;
            }
            if ([service.type isEqualToString:JMRIServiceWeb]) {
                self.webService = (WebService *)service;
                [self.webService startMonitoring];
                self.requiresWebService = YES;
            } else {
                self.useWebService = NO;
            }
            if ([service.type isEqualToString:JMRIServiceWiThrottle]) {
                self.wiThrottleService = (WiThrottleService *)service;
                [self.wiThrottleService startMonitoring];
                self.requiresWiThrottleService = YES;
            } else {
                self.useWiThrottleService = NO;
            }
        }
    }
    return self;
}

- (void)commonInit {
    _lights = [NSMutableDictionary dictionaryWithCapacity:0];
    _memories = [NSMutableDictionary dictionaryWithCapacity:0];
    _metadata = [NSMutableDictionary dictionaryWithCapacity:0];
    _panels = [NSMutableDictionary dictionaryWithCapacity:0];
    _reporters = [NSMutableDictionary dictionaryWithCapacity:0];
    _roster = [NSMutableDictionary dictionaryWithCapacity:0];
    _routes = [NSMutableDictionary dictionaryWithCapacity:0];
    _sensors = [NSMutableDictionary dictionaryWithCapacity:0];
    _signalHeads = [NSMutableDictionary dictionaryWithCapacity:0];
    _turnouts = [NSMutableDictionary dictionaryWithCapacity:0];
    _power = [NSMutableDictionary dictionaryWithCapacity:0];
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
    // Observe self so we can use the delegate does not also have to subscribe to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemAddedToList:)
                                                 name:JMRINotificationItemAdded
                                               object:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    // Do not want to use the XmlIOService if the JsonService is available
    if (self.hasXmlIOService) {
        self.xmlIOService = nil;
        self.useXmlIOService = NO;
        if (self.hasWebService) {
            self.useWebService = YES;
        }
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
    // Use the XmlIOService if the JsonService is not available
    if (!self.hasJsonService && !self.hasXmlIOService) {
        if (web.bonjourService) {
            self.xmlIOService = [[XMLIOService alloc] initWithNetService:web.bonjourService];
        } else {
            self.xmlIOService = [[XMLIOService alloc] initWithName:web.name withAddress:web.addresses[0] withPort:web.port];
        }
        self.useWebService = NO;
        self.useXmlIOService = YES;
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

- (void)list:(NSString *)type {
    if ([type isEqualToString:JMRITypePower]) {
        [self queryPower];
    } else if (self.hasWebService && self.useWebService) {
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

#pragma mark - Utilities

- (NSString *)collectionForType:(NSString *)type {
    if (!_collections) {
        _collections = @{
                         JMRITypeLight: JMRIListLights,
                         JMRITypeMemory: JMRIListMemories,
                         JMRITypePanel: JMRIListPanels,
                         JMRITypeReporter: JMRIListReporters,
                         JMRITypeRosterEntry: JMRITypeRoster,
                         JMRITypeRoute: JMRIListRoutes,
                         JMRITypeSensor: JMRIListSensors,
                         JMRITypeSignalHead: JMRIListSignalHeads,
                         JMRITypeTurnout: JMRIListTurnouts
                         };
    }
    if (_collections[type]) {
        return _collections[type];
    }
    return type;
}

- (NSString *)typeForCollection:(NSString *)collection {
    if (!_types) {
        _types = @{
                   JMRIListLights: JMRITypeLight,
                   JMRIListMemories: JMRITypeMemory,
                   JMRIListPanels: JMRITypePanel,
                   JMRIListReporters: JMRITypeReporter,
                   JMRITypeRoster: JMRITypeRosterEntry,
                   JMRIListRoutes: JMRITypeRoute,
                   JMRIListSensors: JMRITypeSensor,
                   JMRIListSignalHeads: JMRITypeSignalHead,
                   JMRIListTurnouts: JMRITypeTurnout
                   };
    }
    if (_types[collection]) {
        return _types[collection];
    }
    return collection;
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
            if (service.bonjourService) {
                self.xmlIOService = [[XMLIOService alloc] initWithNetService:service.bonjourService];
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
                if (service.bonjourService) {
                    self.xmlIOService = [[XMLIOService alloc] initWithNetService:service.bonjourService];
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
        (void) [[JMRILight alloc] initWithName:light withService:self withProperties:properties];
    }
    [((JMRILight *)[self.lights objectForKey:light]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetMemory:(NSString *)memory withValue:(NSString *)value withProperties:(NSDictionary *)properties {
    if (![self.memories objectForKey:memory]) {
        (void) [[JMRIMemory alloc] initWithName:memory withService:self withProperties:properties];
    }
    [((JMRIMemory *)[self.memories objectForKey:memory]) setValue:value updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetMetadata:(NSString *)metadata withValue:(NSString *)value withProperties:(NSDictionary *)properties {
    if (![self.metadata objectForKey:metadata]) {
        (void) [[JMRIMetadata alloc] initWithName:metadata withService:self withProperties:properties];
    }
}

- (void)JMRINetService:(JMRINetService *)service didGetPowerState:(NSUInteger)state {
    if (![self.power objectForKey:JMRITypePower]) {
        JMRIPower *powerObj = [[JMRIPower alloc] initWithName:JMRITypePower withService:self withProperties:nil];
        [powerObj setState:state updateService:NO];
    }
    [((JMRIPower *)[self.power objectForKey:JMRITypePower]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetReporter:(NSString *)reporter withValue:(NSString *)value withProperties:(NSDictionary *)properties {
    if (![self.memories objectForKey:reporter]) {
        (void) [[JMRIReporter alloc] initWithName:reporter withService:self withProperties:properties];
    }
    [((JMRIMemory *)[self.memories objectForKey:reporter]) setValue:value updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetRoute:(NSString *)route withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.routes objectForKey:route]) {
        (void) [[JMRISensor alloc] initWithName:route withService:self withProperties:properties];
    }
    [((JMRISensor *)[self.sensors objectForKey:route]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetSensor:(NSString *)sensor withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.sensors objectForKey:sensor]) {
        (void) [[JMRISensor alloc] initWithName:sensor withService:self withProperties:properties];
    }
    [((JMRISensor *)[self.sensors objectForKey:sensor]) setState:state updateService:NO];
}

- (void)JMRINetService:(JMRINetService *)service didGetSignalHead:(NSString *)signalHead withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.signalHeads objectForKey:signalHead]) {
        (void) [[JMRISignalHead alloc] initWithName:signalHead withService:self withProperties:properties];
    }
    [((JMRISignalHead *)[self.signalHeads objectForKey:signalHead]) setState:state updateService:NO];
}
- (void)JMRINetService:(JMRINetService *)service didGetTurnout:(NSString *)turnout withState:(NSUInteger)state withProperties:(NSDictionary *)properties {
    if (![self.turnouts objectForKey:turnout]) {
        (void) [[JMRITurnout alloc] initWithName:turnout withService:self withProperties:properties];
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
            [self JMRINetService:service didGetMemory:i.name withValue:i.value withProperties:i.properties];
        }
    } else if ([type isEqualToString:JMRITypeMetadata]) {
        for (XMLIOItem *i in items) {
            [self JMRINetService:service didGetMetadata:i.name withValue:i.value withProperties:i.properties];
        }
    } else if ([type isEqualToString:JMRITypePower]) {
        for (XMLIOItem *i in items) {
            [self JMRINetService:service didGetPowerState:[i.value integerValue]];
        }
    } else if ([type isEqualToString:JMRITypeRoute]) {
        for (XMLIOItem *i in items) {
            [self JMRINetService:service didGetRoute:i.name withState:[i.value integerValue] withProperties:i.properties];
        }
    } else if ([type isEqualToString:JMRITypeSensor]) {
        for (XMLIOItem *i in items) {
            [self JMRINetService:service didGetSensor:i.name withState:[i.value integerValue] withProperties:i.properties];
        }
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        for (XMLIOItem *i in items) {
            [self JMRINetService:service didGetTurnout:i.name withState:[i.value integerValue] withProperties:i.properties];
        }
    }
}

- (void)XMLIOService:(XMLIOService *)service didReadItem:(XMLIOItem *)item withName:(NSString *)aName ofType:(NSString *)type withValue:(NSString *)value {
    if ([type isEqualToString:JMRITypeMemory]) {
        [self JMRINetService:service didGetMemory:item.name withValue:item.value withProperties:item.properties];
    } else if ([type isEqualToString:JMRITypeMetadata]) {
        [self JMRINetService:service didGetMetadata:item.name withValue:item.value withProperties:item.properties];
    } else if ([type isEqualToString:JMRITypePower]) {
        [self JMRINetService:service didGetPowerState:[item.value integerValue]];
    } else if ([type isEqualToString:JMRITypeRoute]) {
        [self JMRINetService:service didGetRoute:item.name withState:[item.value integerValue] withProperties:item.properties];
    } else if ([type isEqualToString:JMRITypeSensor]) {
        [self JMRINetService:service didGetSensor:item.name withState:[item.value integerValue] withProperties:item.properties];
    } else if ([type isEqualToString:JMRITypeTurnout]) {
        [self JMRINetService:service didGetTurnout:item.name withState:[item.value integerValue] withProperties:item.properties];
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

#pragma mark - Private methods

- (void)itemAddedToList:(NSNotification *)notification {
    if ([self.delegate respondsToSelector:@selector(JMRIService:didAddItem:toList:)]) {
        [self.delegate JMRIService:self didAddItem:notification.userInfo[JMRIAddedItem] toList:notification.userInfo[JMRIList]];
    }
}

// Handle power specially when listing, since most services do not allow power to be listed
- (void)queryPower {
    if (!self.power[JMRITypePower]) {
        [self.power setValue:[[JMRIPower alloc] initWithName:JMRITypePower withService:self] forKey:JMRITypePower];
    }
    [(JMRIPower *)self.power[JMRITypePower] query];
}

@end