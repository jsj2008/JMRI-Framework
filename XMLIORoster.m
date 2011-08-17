/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIORoster.m
//  JMRI Framework
//
//  Created by Randall Wood on 31/5/2011.
//

#import "XMLIORoster.h"
#import "XMLIOFunction.h"
#import "XMLIOService.h"
#import "XMLIOThrottle.h"

@implementation XMLIORoster

- (id)init {
	if ((self = [super init])) {
        self.functions = [NSMutableArray arrayWithCapacity:XMLIORosterMaxFunctions];
        for (NSUInteger i = 0; i < XMLIORosterMaxFunctions; i++) {
            [self.functions insertObject:[[[XMLIOFunction alloc] initWithFunctionIdentifier:i] autorelease] atIndex:i];
        }
	}
	return self;
}

/*
 Copy everything from an XMLIOItem into an XMLIORoster
 
 This method is required to support JMRI 2.12 since its impossible to tell when starting to parse an item element if it contains an XMLIOItem or XMLIORoster object.
 */
- (id)initWithItem:(XMLIOItem *)item {
    if ((self = [super init])) {
        // copy everything incase this is not really a roster element
        self.name = item.name;
        self.type = item.type;
        self.userName = item.userName;
        self.value = item.value;
        self.comment = item.comment;
        self.inverted = item.inverted;
        self.dccAddress = item.dccAddress;
        self.addressLength = item.addressLength;
        self.roadName = item.roadName;
        self.roadNumber = item.roadNumber;
        self.mfg = item.mfg;
        self.model = item.model;
        self.maxSpeedPct = item.maxSpeedPct;
        self.imageFileName = item.imageFileName;
        self.imageIconName = item.imageIconName;
        self.functions = item.functions;
    }
    return self;
}

- (NSString *)labelForFunction:(NSInteger)function {
    return [(XMLIOFunction *)[self.functions objectAtIndex:function] label];
}

- (BOOL)lockableForFunction:(NSInteger)function {
    return [(XMLIOFunction *)[self.functions objectAtIndex:function] lockable];
}

- (XMLIOFunction *)functionForKey:(NSString *)key {
    return [self.functions objectAtIndex:[[key substringFromIndex:1] integerValue]];
}

- (XMLIOThrottle *)throttleWithService:(XMLIOService *)service {
    XMLIOThrottle *throttle = [[[XMLIOThrottle alloc] initWithRoster:self withService:service] autorelease];
    return throttle;
}

- (void)dealloc {
    self.functions = nil;
	[super dealloc];
}

@end
