//
//  JsonServiceBrowser.m
//  JMRI-Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JsonServiceBrowser.h"
#import "JsonService.h"
#import "JMRIConstants.h"

@implementation JsonServiceBrowser

- (id)init {
	if ((self = [super init])) {
        _type = JMRIServiceJson;
    }
    return self;
}

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
    NSDictionary *txtRecords = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]];
    if ([txtRecords objectForKey:JMRITXTRecordKeyJSON] && ![self containsService:sender]) {
		JsonService *service = [[JsonService alloc] initWithNetService:sender];
		[self.services addObject:service];
		[self.delegate JMRINetServiceBrowser:self didFindService:service moreComing:_searching];
	}
}

@end
