//
//  JMRIItem.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIItem.h"
#import "JMRIConstants.h"

@implementation JMRIItem

#pragma mark - Initializers

- (id)initWithName:(NSString *)name withService:(JMRINetService *)service {
    if (([super init] != nil)) {
        self.name = name;
        self.service = service;
        self.state = JMRIItemStateUnknown;
    }
    return self;
}

#pragma mark - Communications

- (void)read {
    if ([self.service isKindOfClass:[SimpleService class]]) {
        [self readFromSimpleService];
    } else if ([self.service isKindOfClass:[WiThrottleService class]]) {
        [self readFromWiThrottleService];
    } else if ([self.service isKindOfClass:[XMLIOService class]]) {
        [self readFromXmlIOService];
    }
}

- (void)readFromSimpleService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)readFromWiThrottleService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)readFromXmlIOService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)write {
    if ([self.service isKindOfClass:[SimpleService class]]) {
        [self writeToSimpleService];
    } else if ([self.service isKindOfClass:[WiThrottleService class]]) {
        [self writeToWiThrottleService];
    } else if ([self.service isKindOfClass:[XMLIOService class]]) {
        [self writeToXmlIOService];
    }
}

- (void)writeToSimpleService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)writeToWiThrottleService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)writeToXmlIOService {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Properties

- (NSUInteger)state {
    return _state;
}

- (void)setState:(NSUInteger)state {
    if (_state != state) {
        _state = state;
        if (_state == JMRIItemStateUnknown) {
            [self read];
        } else {
            [self write];
        }
        if ([self.delegate respondsToSelector:@selector(item:didChangeState:)]) {
            [self.delegate item:self didChangeState:self.state];
        }
    }
}

- (void)setState:(NSString *)state forService:(JMRINetService *)service {
    if (service == self.service) {
        if ([self.service isKindOfClass:[SimpleService class]]) {
            [self setStateFromSimpleService:state];
        } else if ([self.service isKindOfClass:[WiThrottleService class]]) {
            [self setStateFromWiThrottleService:state];
        } else if ([self.service isKindOfClass:[XMLIOService class]]) {
            [self setStateFromXmlIOService:state];
        }
        if ([self.delegate respondsToSelector:@selector(item:didChangeState:)]) {
            [self.delegate item:self didChangeState:self.state];
        }
    }
}

@synthesize comment = _comment;
@synthesize delegate = _delegate;
@synthesize inverted = _inverted;
@synthesize name = _name;
@synthesize service = _service;
@synthesize userName = _userName;

@end
