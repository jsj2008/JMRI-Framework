/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOThrottle.m
//  JMRI Framework
//
//  Created by Randall Wood on 31/5/2011.
//

#import "XMLIOThrottle.h"
#import "XMLIOService.h"
#import "XMLIORoster.h"

@implementation XMLIOThrottle

@synthesize forward = forward_;
@synthesize speed = speed_;
@synthesize steps = steps_;

@synthesize service = service_;
@synthesize roster = roster_;
@synthesize commands;
@synthesize shouldSendUpdate;

@synthesize address;

- (void)setForward:(BOOL)forward {
    if (forward != forward_) {
        forward_ = forward;
        [self.commands setValue:(forward_) ? XMLIOBooleanYES : XMLIOBooleanNO forKey:XMLIOThrottleForward];
        [self update];
    }
}

- (void)setSpeed:(float)speed {
    if (speed != speed_) {
        speed_ = speed;
        [self.commands setValue:[[NSNumber numberWithFloat:speed] stringValue] forKey:XMLIOThrottleSpeed];
        [self update];
    }
}

- (void)setState:(NSUInteger)state forFunction:(NSUInteger)function {
    if ([self stateForFunction:function] != state) {
        XMLIOFunction *f = [self.roster.functions objectAtIndex:function];
        f.state = state;
        [self.commands setValue:(state == XMLIOItemStateActive) ? XMLIOBooleanYES : XMLIOBooleanNO forKey:f.key];
        [self update];
    }
}


- (NSUInteger)stateForFunction:(NSUInteger)function {
    if ([self.roster.functions count] > function) {
        return [[self.roster.functions objectAtIndex:function] state];
    }
    return XMLIOItemStateUnknown;
}

- (id)initWithRoster:(XMLIORoster *)roster withService:(XMLIOService *)service {
    if (!roster || !service) {
        return nil;
    }
    if ((self = [super init])) {
        self.shouldSendUpdate = NO;
        self.commands = [NSMutableDictionary dictionaryWithCapacity:0];
        self.roster = roster;
        self.service = service;
        self.steps = 126; // set to 0 to when testing XMLIO server handling of this
        if (!service.useAttributeProtocol) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateWithNotification:)
                                                         name:XMLIOServiceDidGetThrottle 
                                                       object:service];
        }
        self.shouldSendUpdate = YES;
        [self.commands removeAllObjects];
        [service sendThrottle:self.roster.dccAddress commands:nil];
        [service.throttles setObject:self forKey:[[NSNumber numberWithInteger:self.roster.dccAddress] stringValue]];
    }
    return self;
}

- (void)updateFromThrottle:(XMLIOThrottle *)throttle {
    if (throttle.address == self.roster.dccAddress) {
        self.shouldSendUpdate = NO;
        if (throttle.speed) {
            self.speed = throttle.speed;
        }
        if (throttle.forward) {
            self.forward = throttle.forward;
        }
        if (throttle.steps) {
            self.steps = throttle.steps;
        }
        if ([throttle stateForFunction:0]) {
            [self setState:[throttle stateForFunction:0] forFunction:0];
        }
        if ([throttle stateForFunction:1]) {
            [self setState:[throttle stateForFunction:1] forFunction:1];
        }
        if ([throttle stateForFunction:2]) {
            [self setState:[throttle stateForFunction:2] forFunction:2];
        }
        if ([throttle stateForFunction:3]) {
            [self setState:[throttle stateForFunction:3] forFunction:3];
        }
        if ([throttle stateForFunction:4]) {
            [self setState:[throttle stateForFunction:4] forFunction:4];
        }
        if ([throttle stateForFunction:5]) {
            [self setState:[throttle stateForFunction:5] forFunction:5];
        }
        if ([throttle stateForFunction:6]) {
            [self setState:[throttle stateForFunction:6] forFunction:6];
        }
        if ([throttle stateForFunction:7]) {
            [self setState:[throttle stateForFunction:7] forFunction:7];
        }
        if ([throttle stateForFunction:8]) {
            [self setState:[throttle stateForFunction:8] forFunction:8];
        }
        if ([throttle stateForFunction:9]) {
            [self setState:[throttle stateForFunction:9] forFunction:9];
        }
        if ([throttle stateForFunction:10]) {
            [self setState:[throttle stateForFunction:10] forFunction:10];
        }
        if ([throttle stateForFunction:11]) {
            [self setState:[throttle stateForFunction:11] forFunction:11];
        }
        if ([throttle stateForFunction:12]) {
            [self setState:[throttle stateForFunction:12] forFunction:12];
        }
        self.shouldSendUpdate = YES;
    }
}

- (void)updateWithNotification:(NSNotification *)notification {
    [self updateFromThrottle:[[notification userInfo] objectForKey:XMLIOThrottleKey]];
}

- (void)update {
    if (self.shouldSendUpdate) {
        [self.service sendThrottle:self.roster.dccAddress
                          commands:self.commands];
        self.commands = nil;
        self.commands = [NSMutableDictionary dictionaryWithCapacity:0];
    }
}

- (void)dealloc {
    self.service = nil;
    self.commands = nil;
    self.roster = nil;
    [super dealloc];
}

@end
