//
//  JMRIXMLIOServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 11/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIXMLIOServiceBrowser.h"
#import "JMRIXMLIOService.h"

@implementation JMRIXMLIOServiceBrowser

- (void)searchForServices {
	if (self.searching) {
		[self.browser stop];
	}
	[self.browser searchForServicesOfType:JMRIServiceTypeXMLIO inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	JMRIXMLIOService *service = [[[JMRIXMLIOService alloc] initWithAddress:address withPort:port] autorelease];
	[self.services addObject:service];
}
/*
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	if (![self containsService:aNetService]) {
		JMRIXMLIOService *service;
		service = [[[JMRIXMLIOService alloc] initWithNetService:aNetService] autorelease];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRIServiceBrowser:self didFindService:service moreComing:moreComing];
		}
	}
}
*/

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	NSLog(@"JMRIXMLIOService TXT Record: %@", [NSString stringWithUTF8String:[[sender TXTRecordData] bytes]]);
	if (![self containsService:sender]) {
		JMRIXMLIOService *service = [[[JMRIXMLIOService alloc] initWithNetService:sender] autorelease];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRIServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRIServiceBrowser:self didFindService:service moreComing:_searching];
		}
	}
}

@end
