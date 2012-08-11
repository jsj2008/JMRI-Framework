//
//  JMRIPanel.m
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "JMRIPanel.h"
#import "JMRIPanelHelper.h"
#import "JMRIItem+Internal.h"

@implementation JMRIPanel

- (void)query {
    if (self.url) {
        NSURLRequest* request = [NSURLRequest requestWithURL:self.url
                                                 cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                             timeoutInterval:self.service.webService.timeoutInterval];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        JMRIPanelHelper *helper = [[JMRIPanelHelper alloc] initWithDelegate:self
                                                                      withRequest:request];
        [queue addOperation:helper];
	} else if (!self.url) { // did not resolve
		[self.service XMLIOService:self.service.webService didFailWithError:[NSError errorWithDomain:JMRIErrorDomain code:1025 userInfo:nil]];
	} else { // open connection
		[self.service XMLIOService:self.service.webService didFailWithError:[NSError errorWithDomain:JMRIErrorDomain code:1026 userInfo:nil]];
	}
}

- (NSURL *)url {
    if (!self.service.hasWebService || self.service.webService.port == -1) {
		return nil;
	}
	return [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li/panel/%@", self.service.hostName, self.service.webService.port, self.name, nil]] absoluteURL];
}

- (NSString *)type {
    return JMRITypePanel;
}

@end
