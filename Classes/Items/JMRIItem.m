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
#import "SimpleService.h"
#import "WiThrottleService.h"
#import "XMLIOService.h"

@implementation JMRIItem

#pragma mark - Initializers

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    if (([super init] != nil)) {
        self.name = name;
        self.service = service;
        self.state = JMRIItemStateUnknown;
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
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self queryFromSimpleService:self.service.simpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        // WiThrottle has no explicit query mechanism
    } else if (self.service.hasWebService && self.service.useXmlIOService) {
        [self queryFromXmlIOService:self.service.webService];
    }
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
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self writeToSimpleService:self.service.simpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        [self writeToWiThrottleService:self.service.wiThrottleService];
    } else if (self.service.hasWebService && self.service.useXmlIOService) {
        [self writeToXmlIOService:self.service.webService];
    }
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
    if (_state != state) {
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