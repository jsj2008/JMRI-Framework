//
//  JMRINetService.m
//  JMRI Framework
//
//  Created by Randall Wood on 10/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRINetService.h"


@implementation JMRINetService

#pragma mark -
#pragma mark Object handling

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super init])) {
		self.service = service;
		[self.service setDelegate:self];
		self.logTraffic = NO;
		self.timeoutInterval = 60;
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
	}
	return self;
}

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService {
	return [self.name localizedCaseInsensitiveCompare:aService.name];
}

- (void)dealloc {
	[self.service release];
	[self.delegate release];
	manualAddress = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Net service handling

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

- (BOOL)testConnection {
	[self doesNotRecognizeSelector:_cmd];
	return NO;
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

@synthesize delegate = _delegate;
@synthesize service = _service;
@synthesize logTraffic;
@synthesize timeoutInterval;

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

- (NSString *)hostname {
	if (self.service) {
		return [self.service hostName];
	}
	return manualAddress;
}

- (NSString *)name {
	if (self.service) {
		return [self.service name];
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
