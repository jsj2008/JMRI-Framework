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
	[self.browser searchForServicesOfType:JMRINetServiceSimple inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	SimpleService *service = [[SimpleService alloc] initWithAddress:address withPort:port];
	[self.services addObject:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if (![self containsService:sender]) {
		SimpleService *service = [[SimpleService alloc] initWithNetService:sender];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRINetServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRINetServiceBrowser:self didFindService:service moreComing:_searching];
		}
	}
}

@end
