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
#import "JMRIConstants.h"
#import "NSArray+JMRIExtensions.h"

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

#pragma mark - JMRI object handling

- (void)send:(NSString *)message {
    [self doesNotRecognizeSelector:_cmd];
}

#pragma mark - Object handling

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super init])) {
        NSDictionary *txtRecords = [NSNetService dictionaryFromTXTRecordData:[service TXTRecordData]];
		self.bonjourService = service;
		[self.bonjourService setDelegate:self];
		self.timeoutInterval = 60;
        if ([txtRecords objectForKey:JMRITXTRecordKeyJMRI]) {
            serviceVersion = [[NSString alloc] initWithUTF8String:[[txtRecords objectForKey:JMRITXTRecordKeyJMRI] bytes]];
        } else {
            serviceVersion = MIN_JMRI_VERSION;
        }
	}
	return self;
}

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super init])) {
		self.bonjourService = nil;
        manualName = name;
		manualAddress = address;
		manualPort = port;
		self.timeoutInterval = 60;
        serviceVersion = MIN_JMRI_VERSION;
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
}

- (void)dealloc {
	self.delegate = nil;
	manualAddress = nil;
}

#pragma mark - Net service handling

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
	if (self.bonjourService) {
		[self.bonjourService resolveWithTimeout:timeout];
	} else {
		[self.delegate JMRINetServiceDidResolveAddress:self];
	}
}

- (void)startMonitoring {
	if (self.bonjourService) {
		[self.bonjourService startMonitoring];
	}
}

- (void)stop {
    [self stopMonitoring];
}

- (void)stopMonitoring {
	if (self.bonjourService) {
		[self.bonjourService stopMonitoring];
	}
}

- (void)failWithError:(NSError *)error {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)open {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)close {
    [self doesNotRecognizeSelector:_cmd];
}

- (Boolean)isOpen {
    return NO;
}

#pragma mark - Net service delegate

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict {
	NSLog(@"%@ failed to resolve: %@", self.name, errorDict);
    [self.delegate JMRINetService:self didNotResolve:errorDict];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	NSLog(@"%@ resolved", self.name);
    [self.delegate JMRINetServiceDidResolveAddress:self];
}

- (void)netServiceWillResolve:(NSNetService *)sender {
	NSLog(@"%@ will resolve", self.name);
    [self.delegate JMRINetServiceWillResolve:self];
}

#pragma mark - Object properties

@synthesize delegate;
@synthesize bonjourService = netService;
@synthesize timeoutInterval;
@synthesize version = serviceVersion;
@synthesize type = serviceType;

- (BOOL)resolved {
	return (self.port != -1);
}

#pragma mark - Net service properties

- (NSArray *)addresses {
	if (self.bonjourService) {
		return [self.bonjourService addresses];
	}
	return [NSArray arrayWithObject:manualAddress];
}

- (NSString *)domain {
	if (self.bonjourService) {
		return [self.bonjourService domain];
	}
	return nil;
}

- (NSString *)hostName {
	if (self.bonjourService) {
		return [self.bonjourService hostName];
	}
	return manualAddress;
}

- (NSString *)name {
	if (self.bonjourService) {
		return ([[self.bonjourService name] hasPrefix:@"JMRI on "]) ? [[self.bonjourService name] substringFromIndex:8] : [self.bonjourService name];
	}
    return (manualName) ? manualName : manualAddress;
}

- (NSInteger)port {
	if (self.bonjourService) {
		return [self.bonjourService port];
	}
	return manualPort;
}

@end
