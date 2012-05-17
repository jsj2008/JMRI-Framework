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
@synthesize speedStepMode = speedStepMode_;

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
        [self.commands setValue:(state == JMRIItemStateActive) ? XMLIOBooleanYES : XMLIOBooleanNO forKey:f.key];
        [self update];
    }
}

- (NSInteger)steps {
    switch (self.speedStepMode) {
        case XMLIOSpeedStepMode128:
            return 126;
            break;
        case XMLIOSpeedStepMode14:
            return 14;
            break;
        case XMLIOSpeedStepMode27:
            return 27;
            break;
        case XMLIOSpeedStepMode28:
            return 28;
            break;
        default:
            break;
    }
    return NSNotFound;
}

- (NSUInteger)stateForFunction:(NSUInteger)function {
    if ([self.roster.functions count] > function) {
        return [[self.roster.functions objectAtIndex:function] state];
    }
    return JMRIItemStateUnknown;
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
        self.speedStepMode = XMLIOSpeedStepMode128;
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
        if (throttle.speedStepMode) {
            self.speedStepMode = throttle.speedStepMode;
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
        if ([throttle stateForFunction:13]) {
            [self setState:[throttle stateForFunction:13] forFunction:13];
        }
        if ([throttle stateForFunction:14]) {
            [self setState:[throttle stateForFunction:14] forFunction:14];
        }
        if ([throttle stateForFunction:15]) {
            [self setState:[throttle stateForFunction:15] forFunction:15];
        }
        if ([throttle stateForFunction:16]) {
            [self setState:[throttle stateForFunction:16] forFunction:16];
        }
        if ([throttle stateForFunction:17]) {
            [self setState:[throttle stateForFunction:17] forFunction:17];
        }
        if ([throttle stateForFunction:18]) {
            [self setState:[throttle stateForFunction:18] forFunction:18];
        }
        if ([throttle stateForFunction:19]) {
            [self setState:[throttle stateForFunction:19] forFunction:19];
        }
        if ([throttle stateForFunction:20]) {
            [self setState:[throttle stateForFunction:20] forFunction:20];
        }
        if ([throttle stateForFunction:21]) {
            [self setState:[throttle stateForFunction:21] forFunction:21];
        }
        if ([throttle stateForFunction:22]) {
            [self setState:[throttle stateForFunction:22] forFunction:22];
        }
        if ([throttle stateForFunction:23]) {
            [self setState:[throttle stateForFunction:23] forFunction:23];
        }
        if ([throttle stateForFunction:24]) {
            [self setState:[throttle stateForFunction:24] forFunction:24];
        }
        if ([throttle stateForFunction:25]) {
            [self setState:[throttle stateForFunction:25] forFunction:25];
        }
        if ([throttle stateForFunction:26]) {
            [self setState:[throttle stateForFunction:26] forFunction:26];
        }
        if ([throttle stateForFunction:27]) {
            [self setState:[throttle stateForFunction:27] forFunction:27];
        }
        if ([throttle stateForFunction:28]) {
            [self setState:[throttle stateForFunction:28] forFunction:28];
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


@end
