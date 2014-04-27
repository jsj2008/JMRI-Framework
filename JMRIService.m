//
//  JMRIService.m
//  JMRI-Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIService.h"
#import "JMRIService+Internal.h"
#import "JsonService.h"
#import "WebService.h"
#import "WiThrottleService.h"
#import "JMRIConstants.h"
#import "JMRIItem+Internal.h"
#import "JMRILight.h"
#import "JMRIMemory.h"
#import "JMRIMetadata.h"
#import "JMRIPower.h"
#import "JMRIReporter.h"
#import "JMRIReporter+Internal.h"
#import "JMRISensor.h"
#import "JMRISignalHead.h"
#import "JMRITurnout.h"

@interface JMRIService (Private) <JMRINetServiceDelegate>

- (void)commonInit;

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
        if ([ports valueForKey:JMRIServiceWeb]) {
            self.webService = [[WebService alloc] initWithName:name withAddress:address withPort:[ports[JMRIServiceWeb] integerValue]];
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
    self.requiresWebService = NO;
    self.requiresWiThrottleService = NO;
    self.useJsonService = YES;
    self.useWebService = YES;
    self.useWiThrottleService = YES;
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
    self.useJsonService = YES;
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
    if (web.bonjourService) {
        if (!web.txtRecords[JMRITXTRecordKeyJSON]) {
            self.useWebService = NO;
        }
    } else {
        [web list:JMRITypeHello];
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

- (Boolean)hasJsonService {
    return (self.jsonService != nil);
}

- (Boolean)hasWebService {
    return (self.webService != nil);
}

- (Boolean)hasWiThrottleService {
    return (self.wiThrottleService != nil);
}

- (NSString *)version {
    if (self.hasJsonService) {
        return self.jsonService.version;
    } else if (self.hasWebService) {
        return self.webService.version;
    } else {
        return self.wiThrottleService.version;
    }
}

@synthesize requiresWiThrottleService = _requiresWiThrottleService;
@synthesize useWiThrottleService = _useWiThrottleService;

#pragma mark - JMRI Elements

- (void)list:(NSString *)type {
    if ([type isEqualToString:JMRITypePower]) {
        [self queryPower];
    } else if (self.hasWebService && self.useWebService) {
        [self.webService list:type];
    } else if (self.hasJsonService && self.useJsonService) {
        [self.jsonService list:type];
    }
}

- (void)stop {
    [self.jsonService stop];
    [self.webService stop];
    [self.wiThrottleService stop];
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

- (void)logEvent:(NSString *)format, ... {
    if (self.logEvents) {
        va_list args;
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:[@"JMRI Service: " stringByAppendingString:format] arguments:args];
        va_end(args);
        NSLog(@"%@", message);
    }
}

#pragma mark - JMRINetService delegate

- (void)JMRINetService:(JMRINetService *)service didNotResolve:(NSDictionary *)errorDict {
    // JMRIService probably needs to handle this itself, but I'm not sure how
    if ([self.delegate respondsToSelector:@selector(JMRIService:didNotResolve:)]) {
        [self.delegate JMRIService:self didNotResolve:errorDict];
    }
}

- (void)JMRINetService:(JMRINetService *)service didFailWithError:(NSError *)error {
    // error.domain JMRIErrorDomain + error.code JMRIWebServiceJsonUnsupported = JMRI too old
    if ([error.domain isEqualToString:JMRIErrorDomain]) {
        if (error.code == JMRIWebServiceJsonUnsupported) {
            // do we need to do anything here?
        }
    }
    if ([self.delegate respondsToSelector:@selector(JMRIService:didFailWithError:)]) {
        [self.delegate JMRIService:self didFailWithError:error];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationDidFailWithError object:self userInfo:@{JMRITypeError: error}];
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
    if (![self.reporters objectForKey:reporter]) {
        (void) [[JMRIReporter alloc] initWithName:reporter withService:self withProperties:properties];
    }
    [((JMRIReporter *)[self.reporters objectForKey:reporter]) setReport:properties[JMRIItemReport] withLastReport:properties[JMRIItemLastReport] updateService:NO];
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
    [self logEvent:@"%@ received %@", service.type, input];
    if ([self.delegate respondsToSelector:@selector(JMRIService:didGetInput:)]) {
        [self.delegate JMRIService:self didGetInput:input];
    }
}

- (void)JMRINetService:(JMRINetService *)service didSend:(NSData *)data {
    [self logEvent:@"%@ sent %@", service.type, [NSString stringWithUTF8String:data.bytes]];
}

- (void)JMRINetServiceDidOpenConnection:(JMRINetService *)service {
    [self logEvent:@"%@ opened connection", service.type];
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidOpenConnection:)]) {
        [self.delegate JMRIServiceDidOpenConnection:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationDidOpenConnection object:self userInfo:nil];
}

- (void)JMRINetServiceDidCloseConnection:(JMRINetService *)service {
    [self logEvent:@"%@ closed connection", service.type];
    if ([self.delegate respondsToSelector:@selector(JMRIServiceDidCloseConnection:)]) {
        [self.delegate JMRIServiceDidCloseConnection:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationDidCloseConnection object:self userInfo:nil];
}

- (void)JMRINetServiceDidStart:(JMRINetService *)service {
    [self logEvent:@"%@ started", service.type];
    if ([self.delegate respondsToSelector:@selector(JMRIService:didStart:)]) {
        [self.delegate JMRIService:self didStart:service];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationDidStart object:self userInfo:@{JMRIServiceKey:service}];
}

- (void)JMRINetServiceDidStop:(JMRINetService *)service {
    [self logEvent:@"%@ stopped", service.type];
    if ([self.delegate respondsToSelector:@selector(JMRIService:didStop:)]) {
        [self.delegate JMRIService:self didStop:service];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationDidStop object:self userInfo:@{JMRIServiceKey:service}];
}

- (void)JMRINetService:(JMRINetService *)service didWrite:(NSData *)data {
    [self logEvent:@"%@ wrote %@", service.type, [data description]];
}

- (void)useJsonServiceWithURL:(NSURL *)url {
    if (!self.jsonService) {
        self.jsonService = [[JsonService alloc] initWithName:self.name withURL:url];
    } else {
        self.jsonService.webSocketURL = url;
    }
}

#pragma mark - Private methods

// Post a notification when an item is added to a list
- (void)item:(JMRIItem *)item addedToList:(NSDictionary *)list {
    if ([self.delegate respondsToSelector:@selector(JMRIService:didAddItem:toList:)]) {
        [self.delegate JMRIService:self didAddItem:item toList:list];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationItemAdded
                                                        object:self
                                                      userInfo:@{
                                                JMRIServiceKey: self,
                                                   JMRIItemKey: item,
                                                      JMRIList: list,
                                                      JMRIType: item.type}];
}

// Handle power specially when listing, since most services do not allow power to be listed
- (void)queryPower {
    if (!self.power[JMRITypePower]) {
        [self.power setValue:[[JMRIPower alloc] initWithName:JMRITypePower withService:self] forKey:JMRITypePower];
    }
    [(JMRIPower *)self.power[JMRITypePower] query];
}

@end
