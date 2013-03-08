/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRINetService.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/5/2011.
//

#define MIN_JMRI_VERSION @"2.14"

#import <Foundation/Foundation.h>

@interface JMRINetService : NSObject <NSNetServiceDelegate> {

	NSNetService *netService;
    NSTimeInterval timeoutInterval;
	BOOL logTraffic;
    NSString *manualName;
	NSString *manualAddress;
	NSInteger manualPort;
    NSString *serviceVersion;
    NSString *serviceType;

    @private
    //NSMutableDictionary *servers_;

}

#pragma mark - Object handling

- (id)initWithNetService:(NSNetService *)service;
- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port;
- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port;
- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(JMRINetService*)aService;

#pragma mark - Net service handling

- (void)resolveWithTimeout:(NSTimeInterval)timeout;
- (void)startMonitoring;
- (void)stop;
- (void)stopMonitoring;
- (void)failWithError:(NSError *)error;

#pragma mark - JMRI object handling

- (void)send:(NSString *)message;

#pragma mark - Object properties

@property (weak, nonatomic) id delegate;
@property NSNetService *service;
@property BOOL logTraffic;
@property NSTimeInterval timeoutInterval;
@property (readonly) BOOL resolved;
@property (readonly) NSString *version;
@property (readonly) NSString *type;

#pragma mark - Net service properties

@property (readonly) NSArray *addresses;
@property (readonly) NSString *domain;
@property (readonly) NSString *hostName;
@property (readonly) NSString *name;
@property (readonly) NSInteger port;

@end

#pragma mark -

@protocol JMRINetServiceDelegate

#pragma mark - Required
@required
- (void)JMRINetService:(JMRINetService *)service didNotResolve:(NSDictionary *)errorDict;
- (void)JMRINetService:(JMRINetService *)service didFailWithError:(NSError *)error;

#pragma mark - Bonjour resolution (optional)
@optional
- (void)JMRINetServiceDidResolveAddress:(JMRINetService *)service;
- (void)JMRINetServiceWillResolve:(JMRINetService *)service;

#pragma mark - JMRI items (optional)
@optional
- (void)JMRINetService:(JMRINetService *)service didGetLight:(NSString *)light withState:(NSUInteger)state;
- (void)JMRINetService:(JMRINetService *)service didGetMemory:(NSString *)memory withValue:(NSString *)value;
- (void)JMRINetService:(JMRINetService *)service didGetPowerState:(NSUInteger)state;
- (void)JMRINetService:(JMRINetService *)service didGetReporter:(NSString *)reporter withValue:(NSString *)value;
- (void)JMRINetService:(JMRINetService *)service didGetSensor:(NSString *)sensor withState:(NSUInteger)state;
- (void)JMRINetService:(JMRINetService *)service didGetSignalHead:(NSString *)signalHead withState:(NSUInteger)state;
- (void)JMRINetService:(JMRINetService *)service didGetTurnout:(NSString *)turnout withState:(NSUInteger)state;

#pragma mark - Service events (optional)
@optional
- (void)JMRINetService:(JMRINetService *)service didReceive:(NSString *)input;
- (void)JMRINetService:(JMRINetService *)service didSend:(NSData *)data;
- (void)JMRINetServiceDidOpenConnection:(JMRINetService *)service;

@end