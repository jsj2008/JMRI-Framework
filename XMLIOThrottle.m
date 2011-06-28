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

- (id)initWithAddress:(NSUInteger)address withService:(XMLIOService *)service {
    if ((self = [super init])) {
        address_ = address;
        self.service = service;
        if (service) {
            [service sendThrottle:address commands:nil];
        }
    }
    return self;
}

@end
