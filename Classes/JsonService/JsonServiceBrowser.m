//
//  JsonServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JsonServiceBrowser.h"
#import "JsonService.h"

@implementation JsonServiceBrowser

- (void)searchForServices {
	if (self.searching) {
		[self.browser stop];
	}
	[self.browser searchForServicesOfType:JMRINetServiceJson inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	JsonService *service = [[JsonService alloc] initWithAddress:address withPort:port];
	[self.services addObject:service];
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if (![self containsService:sender]) {
		JsonService *service = [[JsonService alloc] initWithNetService:sender];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRINetServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRINetServiceBrowser:self didFindService:service moreComing:_searching];
		}
	}
}

@end
