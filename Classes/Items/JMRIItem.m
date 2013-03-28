//
//  JMRIItem.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIItem+Internal.h"
#import "JMRIConstants.h"
#import "JMRINetService.h"
#import "JsonService.h"
#import "SimpleService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"

@implementation JMRIItem

#pragma mark - Initializers

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    return [self initWithName:name withService:service withProperties:nil];
}

- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties {
    if ((self = [super init])) {
        self.name = name;
        self.service = service;
        self.comment = properties[@"comment"];
        self.userName = properties[@"userName"];
        self.inverted = [properties[@"inverted"] boolValue];
        if (properties[@"state"]) {
            _state = [properties[@"state"] integerValue];
        } else if (properties[@"value"]) {
            _state = JMRIItemStateStateless;
            _value = properties[@"value"];
        } else {
            _state = JMRIItemStateUnknown;
        }
    }
    return self;
}

#pragma mark - Communications

- (void)monitor {
    // monitoring is not automatic in XmlIO, so support a special monitor command
    // for that protocol. Otherwise treat a monitor request as a normal read
    [self query];
    [self.service monitor:self];
}

- (Boolean)isMonitoring {
    return [self.service isMonitoring:self];
}

- (void)stopMonitoring {
    [self.service stopMonitoring:self];
}

- (void)query {
    if (self.service.hasJsonService && self.service.useJsonService) {
        [self queryFromJsonService:self.service.jsonService];
    } else if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self queryFromSimpleService:self.service.simpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        // WiThrottle has no explicit query mechanism
    } else if (self.service.hasXmlIOService && self.service.useXmlIOService) {
        [self queryFromXmlIOService:self.service.xmlIOService];
    }
}

- (void)queryFromJsonService:(JsonService *)service {
    // silently do nothing if not supported by protocol
}

- (void)queryFromSimpleService:(SimpleService *)service {
    // silently do nothing if not supported by protocol
}

- (void)queryFromWiThrottleService:(WiThrottleService *)service {
    // silently do nothing if not supported by protocol
}

- (void)queryFromXmlIOService:(XMLIOService *)service {
    // silently do nothing if not supported by protocol
}

- (void)write {
    if (self.service.hasJsonService && self.service.useJsonService) {
        [self writeToJsonService:self.service.jsonService];
    } else if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self writeToSimpleService:self.service.simpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        [self writeToWiThrottleService:self.service.wiThrottleService];
    } else if (self.service.hasXmlIOService && self.service.useXmlIOService) {
        [self writeToXmlIOService:self.service.xmlIOService];
    }
}

- (void)writeToJsonService:(JsonService *)service {
    //silently do nothing if not supported by protocol
}

- (void)writeToSimpleService:(SimpleService *)service {
    // silently do nothing if not supported by protocol
}

- (void)writeToWiThrottleService:(WiThrottleService *)service {
    // silently do nothing if not supported by protocol
}

- (void)writeToXmlIOService:(XMLIOService *)service {
    // silently do nothing if not supported by protocol
}

#pragma mark - Properties

- (NSUInteger)state {
    return _state;
}

- (void)setState:(NSUInteger)state {
    [self setState:state updateService:YES];
}

- (void)setState:(NSUInteger)state updateService:(Boolean)update {
    if (_state != JMRIItemStateStateless && _state != state) {
        _state = state;
        if (update) {
            if (_state == JMRIItemStateUnknown) {
                [self query];
            } else {
                [self write];
            }
        }
        if ([self.delegate respondsToSelector:@selector(item:didChangeState:)]) {
            [self.delegate item:self didChangeState:self.state];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"changedState" object:self];
    }
}    

- (NSString *)value {
    if (self.state == JMRIItemStateStateless) {
        return _value;
    }
    return [[NSNumber numberWithInteger:self.state] stringValue];
}

- (void)setValue:(NSString *)value {
    [self setValue:value updateService:YES];
}

- (void)setValue:(NSString *)value updateService:(Boolean)update {
    if (self.state == JMRIItemStateStateless) {
        if (![_value isEqualToString:value]) {
            if ([value isEqualToString:@""]) {
                _value = nil;
            } else {
                _value = value;
            }
            if (update) {
                if (!_value) {
                    [self query];
                } else {
                    [self write];
                }
            }
            if ([self.delegate respondsToSelector:@selector(item:didGetValue:)]) {
                [self.delegate item:self didGetValue:self.value];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:@"changedValue" object:self];
        }
    } else {
        [self setState:[value integerValue] updateService:update];
    }
}

- (NSString *)type {
    [self doesNotRecognizeSelector:_cmd];
    return @"";
}

@synthesize comment = _comment;
@synthesize delegate = _delegate;
@synthesize inverted = _inverted;
@synthesize name = _name;
@synthesize service = _service;
@synthesize userName = _userName;

@end