//
//  JMRIItem.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIItem.h"
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
    if (self.service.hasWebService && self.service.useXmlIOService) {
        [self monitorWithXmlIOService];
    } else {
        [self read];
    }
}

- (void)monitorWithXmlIOService {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)read {
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self readFromSimpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        [self readFromWiThrottleService];
    } else if (self.service.hasWebService && self.service.useXmlIOService) {
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
    if (self.service.hasSimpleService && self.service.useSimpleService) {
        [self writeToSimpleService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        [self writeToWiThrottleService];
    } else if (self.service.hasWebService && self.service.useXmlIOService) {
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
    [self setState:state updateService:YES];
}

- (void)setState:(NSUInteger)state updateService:(Boolean)update {
    if (_state != state) {
        _state = state;
        if (update) {
            if (_state == JMRIItemStateUnknown) {
                [self read];
            } else {
                [self write];
            }
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
