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

@implementation XMLIOThrottle

@synthesize address = address_;
@synthesize forward;
@synthesize speed;
@synthesize F0;
@synthesize F1;
@synthesize F2;
@synthesize F3;
@synthesize F4;
@synthesize F5;
@synthesize F6;
@synthesize F7;
@synthesize F8;
@synthesize F9;
@synthesize F10;
@synthesize F11;
@synthesize F12;

@synthesize service = service_;
@synthesize shouldSendUpdate;

- (id)initWithAddress:(NSUInteger)address withService:(XMLIOService *)service {
    if (!service) {
        return nil;
    }
    if ((self = [super init])) {
        self.shouldSendUpdate = YES;
        self.address = address;
        self.service = service;
        [service sendThrottle:address commands:nil];
        [service.throttles setObject:self forKey:[[NSNumber numberWithInteger:address] stringValue]];
        if (!service.useAttributeProtocol) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(updateWithNotification:)
                                                         name:XMLIOServiceDidGetThrottle 
                                                       object:service];
        }
    }
    return self;
}

- (void)setFunctions:(NSArray *)functions {
    for (NSUInteger i = 0; i < 13; i++) {
        XMLIOFunction *f = ([functions count] > i) ? [functions objectAtIndex:i] : [[XMLIOFunction alloc] initWithFunctionIdentifier:i];
        f.throttle = self;
        [self setValue:f forKey:[NSString stringWithFormat:@"F%lu", i]];
    }
}

- (void)updateFromThrottle:(XMLIOThrottle *)throttle {
    if (throttle.address == self.address) {
        self.shouldSendUpdate = NO;
        if (throttle.speed) {
            self.speed = throttle.speed;
        }
        if (throttle.forward) {
            self.forward = throttle.forward;
        }
        if (throttle.F0) {
            self.F0.state = throttle.F0.state;
        }
        if (throttle.F1) {
            self.F1.state = throttle.F1.state;
        }
        if (throttle.F2) {
            self.F2.state = throttle.F2.state;
        }
        if (throttle.F3) {
            self.F3.state = throttle.F3.state;
        }
        if (throttle.F4) {
            self.F4.state = throttle.F4.state;
        }
        if (throttle.F5) {
            self.F5.state = throttle.F5.state;
        }
        if (throttle.F6) {
            self.F6.state = throttle.F6.state;
        }
        if (throttle.F7) {
            self.F7.state = throttle.F7.state;
        }
        if (throttle.F8) {
            self.F8.state = throttle.F8.state;
        }
        if (throttle.F9) {
            self.F9.state = throttle.F9.state;
        }
        if (throttle.F10) {
            self.F10.state = throttle.F10.state;
        }
        if (throttle.F11) {
            self.F11.state = throttle.F11.state;
        }
        if (throttle.F12) {
            self.F12.state = throttle.F12.state;
        }
        self.shouldSendUpdate = YES;
    }
}

- (void)updateWithNotification:(NSNotification *)notification {
    [self updateFromThrottle:[[notification userInfo] objectForKey:XMLIOThrottleKey]];
}

- (void)dealloc {
    self.F0 = nil;
    self.F1 = nil;
    self.F2 = nil;
    self.F3 = nil;
    self.F4 = nil;
    self.F5 = nil;
    self.F6 = nil;
    self.F7 = nil;
    self.F8 = nil;
    self.F9 = nil;
    self.F10 = nil;
    self.F11 = nil;
    self.F12 = nil;
    self.service = nil;
    [super dealloc];
}

@end
