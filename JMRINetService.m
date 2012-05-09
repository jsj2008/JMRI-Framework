/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRINetService.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/5/2011.
//

#import "JMRINetService.h"

NSString *const JMRIServiceSimple = @"JMRINetwork";
NSString *const JMRIServiceXmlIO = @"WebServer";
NSString *const JMRIServiceWiThrottle = @"wiThrottle";

NSString *const JMRITypeFrame = @"frame";
NSString *const JMRITypeMemory = @"memory";
NSString *const JMRITypeMetadata = @"metadata";
NSString *const JMRITypePanel = @"panel";
NSString *const JMRITypePower = @"power";
NSString *const JMRITypeRoster = @"roster";
NSString *const JMRITypeRoute = @"route";
NSString *const JMRITypeSensor = @"sensor";
NSString *const JMRITypeTurnout = @"turnout";

NSString *const JMRITXTRecordKeyJMRI = @"jmri";

static JMRINetService *sharedNetService_ = nil;

@implementation JMRINetService

#pragma mark - Shared instance

+ (void)initialize {
    if (!sharedNetService_) {
        sharedNetService_ = [[JMRINetService alloc] init];
    }
}

+ (JMRINetService *)sharedNetService {
    return sharedNetService_;
}

#pragma mark - JMRI Object handling

@synthesize items;

- (void)readItem:(NSString *)name ofType:(NSString *)type {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
    // default implementation simply attempts a read w/o initial value
    [self readItem:name ofType:type];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
	[self doesNotRecognizeSelector:_cmd];
}

#pragma mark -
#pragma mark Object handling

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super init])) {
        NSDictionary *txtRecords = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
		self.service = service;
		[self.service setDelegate:self];
		self.logTraffic = NO;
		self.timeoutInterval = 60;
        if ([txtRecords objectForKey:JMRITXTRecordKeyJMRI]) {
            version_ = [[NSString alloc] initWithUTF8String:[[txtRecords objectForKey:JMRITXTRecordKeyJMRI] bytes]];
        } else {
            version_ = MIN_JMRI_VERSION;
        }
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super init])) {
		self.service = nil;
		self.logTraffic = NO;
		manualAddress = [address retain];
		manualPort = port;
		self.timeoutInterval = 60;
        version_ = MIN_JMRI_VERSION;
	}
	return self;
}

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
}

- (void)dealloc {
	self.service = nil;
	self.delegate = nil;
	manualAddress = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Net service handling

/**
 * Resolve addresses for a discovered service within the given time limit.
 *
 * Resolves the address or address for a service within <em>timeout</em> seconds. If the service was manually input,
 * this method immediately calls JMRINetServiceDidResolveAddress: on the delegete.
 *
 * @return void
 * @param  NSTimeInterval
 */
- (void)resolveWithTimeout:(NSTimeInterval)timeout {
	if (self.service) {
		[self.service resolveWithTimeout:timeout];
	} else if ([self.delegate respondsToSelector:@selector(JMRINetServiceDidResolveAddress:)]) {
		[self.delegate JMRINetServiceDidResolveAddress:self];
	}
}

- (void)startMonitoring {
	if (self.service) {
		[self.service startMonitoring];
	}
}

- (void)stop {
	if (self.service) {
		[self.service stop];
	}
}

- (void)stopMonitoring {
	if (self.service) {
		[self.service stopMonitoring];
	}
}

#pragma mark -
#pragma mark Net service delegate

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"%@ failed to resolve: %@", self.name, errorDict);
	if ([self.delegate respondsToSelector:@selector(JMRINetService:didNotResolve:)]) {
		[self.delegate JMRINetService:self didNotResolve:errorDict];
	}
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	NSLog(@"%@ resolved", self.name);
	if ([self.delegate respondsToSelector:@selector(JMRINetServiceDidResolveAddress:)]) {
		[self.delegate JMRINetServiceDidResolveAddress:self];
	}
}

- (void)netServiceWillResolve:(NSNetService *)sender {
	NSLog(@"%@ will resolve", self.name);
	if ([self.delegate respondsToSelector:@selector(JMRINetServiceWillResolve:)]) {
		[self.delegate JMRINetServiceWillResolve:self];
	}
}

#pragma mark -
#pragma mark Object properties

@synthesize delegate;
@synthesize service = _service;
@synthesize logTraffic;
@synthesize timeoutInterval;
@synthesize version = version_;
@synthesize type = serviceType;

- (BOOL)resolved {
	return (self.port != -1);
}

#pragma mark -
#pragma mark Net service properties

- (NSArray *)addresses {
	if (self.service) {
		return [self.service addresses];
	}
	return [NSArray arrayWithObject:manualAddress];
}

- (NSString *)domain {
	if (self.service) {
		return [self.service domain];
	}
	return nil;
}

- (NSString *)hostName {
	if (self.service) {
		return [self.service hostName];
	}
	return manualAddress;
}

- (NSString *)name {
	if (self.service) {
		return ([[self.service name] hasPrefix:@"JMRI on "]) ? [[self.service name] substringFromIndex:8] : [self.service name];
	}
	return manualAddress;
}

- (NSInteger)port {
	if (self.service) {
		return [self.service port];
	}
	return manualPort;
}

@end
