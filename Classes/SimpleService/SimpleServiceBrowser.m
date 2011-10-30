//
//  SimpleServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 29/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "SimpleServiceBrowser.h"
#import "SimpleService.h"

@implementation SimpleServiceBrowser

- (void)searchForServices {
	if (self.searching) {
		[self.browser stop];
	}
	[self.browser searchForServicesOfType:JMRIServiceTypeSimple inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	SimpleService *service = [[[SimpleService alloc] initWithAddress:address withPort:port] autorelease];
	[self.services addObject:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if (![self containsService:sender]) {
		SimpleService *service = [[[SimpleService alloc] initWithNetService:sender] autorelease];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRIServiceBrowser:self didFindService:service moreComing:_searching];
		}
	}
}

@end
