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
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

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
	return [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li/panel/%@", self.service.hostName, (long)self.service.webService.port, self.name, nil]] absoluteURL];
}

- (NSString *)type {
    return JMRITypePanel;
}

#pragma mark - Panel helper delegate

- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didConnectWithRequest:(NSURLRequest *)request {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didConnect" object:self];
}

- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFailWithError" object:self userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

- (void)JMRIPanelHelper:(JMRIPanelHelper *)helper didReadItem:(JMRIPanelItem *)item {
    if ([self.items valueForKey:item.item.name] && item != [self.items valueForKey:item.item.name]) {
        if ([[self.items valueForKey:item.item.name] isKindOfClass:[NSMutableArray class]]) {
            [((NSMutableArray *)[self.items valueForKey:item.item.name]) addObject:item];
        } else {
            [self.items setValue:[NSMutableArray arrayWithObjects:item, [self.items valueForKey:item.item.name], nil] forKey:item.item.name];
        }
    } else {
        [self.items setValue:item forKey:item.item.name];
    }
    if (item.level > self.levels) {
        self.levels = item.level;
    }
}

- (void)JMRIPanelHelperDidFinishLoading:(JMRIPanelHelper *)helper {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didFinishLoading" object:self];
}

@end
