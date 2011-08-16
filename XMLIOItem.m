/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOItem.m
//  JMRI Framework
//
//  Created by Randall Wood on 26/5/2011.
//

#import "XMLIOItem.h"
#import "XMLIOService.h"
#import "XMLIOFunction.h"

@implementation XMLIOItem

@synthesize name = systemName;
@synthesize type;
@synthesize userName;
@synthesize value;
@synthesize comment;
@synthesize inverted;

@synthesize dccAddress;
@synthesize addressLength;
@synthesize roadName;
@synthesize roadNumber;
@synthesize mfg;
@synthesize model;
@synthesize maxSpeedPct;
@synthesize imageFileName;
@synthesize imageIconName;
@synthesize functions;

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(XMLIOItem *)item {
	if (self.userName && item.userName) {
		return [self.userName localizedCaseInsensitiveCompare:item.userName];
	} else if (self.userName && item.name) {
		return [self.userName localizedCaseInsensitiveCompare:item.name];
 	} else if (self.name && item.userName) {
		return [self.name localizedCaseInsensitiveCompare:item.userName];
	}
	return [self.name localizedCaseInsensitiveCompare:item.name];
}

- (id)init {
	if ((self = [super init])) {
		self.name = nil;
		self.type = nil;
		self.userName = nil;
		self.value = nil;
		self.comment = nil;
		self.inverted = NO;
		self.dccAddress = 0;
		self.addressLength = nil;
		self.roadName = nil;
		self.roadNumber = 0;
		self.mfg = nil;
		self.model = nil;
		self.maxSpeedPct = 0.0;
		self.imageFileName = nil;
		self.imageIconName = nil;
        self.functions = [NSMutableArray arrayWithCapacity:XMLIORosterMaxFunctions];
        for (NSUInteger i = 0; i < XMLIORosterMaxFunctions; i++) {
            [self.functions insertObject:[[[XMLIOFunction alloc] initWithFunctionIdentifier:i] autorelease] atIndex:i];
        }
	}
	return self;
}

- (void)dealloc {
	self.name = nil;
	self.type = nil;
	self.userName = nil;
	self.value = nil;
	self.comment = nil;
	self.addressLength = nil;
	self.roadName = nil;
	self.mfg = nil;
	self.model = nil;
	self.imageFileName = nil;
	self.imageIconName = nil;
    self.functions = nil;
	[super dealloc];
}

@end
