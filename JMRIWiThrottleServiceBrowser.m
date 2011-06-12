//
//  JMRIWiThrottleServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 11/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIWiThrottleServiceBrowser.h"
#import "JMRIWiThrottleService.h"

@implementation JMRIWiThrottleServiceBrowser

- (void)searchForServices {
	[self.browser searchForServicesOfType:JMRIServiceTypeWiThrottle inDomain:@""];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	JMRIWiThrottleService *service;
	service = [[[JMRIWiThrottleService alloc] initWithNetService:aNetService] autorelease];
	[self.services addObject:service];
	if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
		[self.delegate JMRIServiceBrowser:self didFindService:service moreComing:moreComing];
	}	
}

@end
