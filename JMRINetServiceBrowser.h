/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRINetServiceBrowser.h
//  JMRI Framework
//
//  Created by Randall Wood on 7/5/2011.
//

#import "WiThrottleService.h"
#import "XMLIOService.h"
#import "NSArray+JMRIExtensions.h"

extern NSString *const JMRINetServiceJson;
extern NSString *const JMRINetServiceSimple;
extern NSString *const JMRINetServiceWiThrottle;
extern NSString *const JMRINetServiceWeb;

@interface JMRINetServiceBrowser : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate> {

	NSNetServiceBrowser *_browser;
	BOOL _searching;
    NSString *_type;
	NSMutableArray *_services;
}

#pragma mark Service browser methods

- (void)searchForServices;
- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port;
- (void)stop;

#pragma mark - Utility methods

- (BOOL)containsService:(NSNetService *)service;
- (void)sortServices;
- (NSUInteger)indexOfServiceWithName:(NSString *)name;
- (JMRINetService *)serviceWithName:(NSString *)name;

#pragma mark - Properties

@property (strong, nonatomic) NSNetServiceBrowser *browser;
@property (weak, nonatomic) id delegate;
@property (readonly) BOOL searching;
@property (nonatomic) NSMutableArray *services;
@property (nonatomic) NSMutableSet *unresolvedServices;
@property (readonly, strong) NSString *type;

@end

#pragma mark - JMRI service browser delegate protocol

@protocol JMRINetServiceBrowserDelegate

@required
- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didNotSearch:(NSDictionary *)errorDict;

@optional
- (void)JMRINetServiceBrowserWillSearch:(JMRINetServiceBrowser *)browser;
- (void)JMRINetServiceBrowserDidStopSearch:(JMRINetServiceBrowser *)browser;
- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didFindService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing;
- (void)JMRINetServiceBrowser:(JMRINetServiceBrowser *)browser didRemoveService:(JMRINetService *)aNetService moreComing:(BOOL)moreComing;

@end