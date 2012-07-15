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

- (void)readState {
    [self doesNotRecognizeSelector:_cmd];
}

- (void)writeState {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Properties

- (NSUInteger)state {
    return _state;
}

- (void)setState:(NSUInteger)aState {
    if (_state != aState) {
        _state = aState;
        if (_state == JMRIItemStateUnknown) {
            [self readState];
        } else {
            [self writeState];
        }
        if ([self.delegate respondsToSelector:@selector(item:didChangeState:)]) {
            [self.delegate item:self didChangeState:self.state];
        }
    }
}

- (void)setState:(NSUInteger)aState withService:(JMRINetService *)service {
    if (service == self.service) {
        _state = aState;
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
