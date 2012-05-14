/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOServiceBrowser.m
//  JMRI Framework
//
//  Created by Randall Wood on 11/5/2011.
//

#import "XMLIOServiceBrowser.h"
#import "XMLIOService.h"

@implementation XMLIOServiceBrowser

- (void)searchForServices {
	if (self.searching) {
		[self.browser stop];
	}
	[self.browser searchForServicesOfType:JMRINetServiceXmlIO inDomain:@""];
}

- (void)addServiceWithAddress:(NSString *)address withPort:(NSInteger)port {
	XMLIOService *service = [[XMLIOService alloc] initWithAddress:address withPort:port];
	[self.services addObject:service];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
	if (![self containsService:aNetService]) {
		XMLIOService *service;
		service = [[XMLIOService alloc] initWithNetService:aNetService];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRINetServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRINetServiceBrowser:self didFindService:service moreComing:moreComing];
		}
	}
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSDictionary *txtRecords = [NSNetService dictionaryFromTXTRecordData:[sender TXTRecordData]];
    // the test for path=index.html should hopefully be only temporary && JMRI post 2.13 should have a jmri=version instead
    if (([txtRecords objectForKey:JMRITXTRecordKeyJMRI] || [txtRecords objectForKey:@"path"]) &&
        ![self containsService:sender]) {
		XMLIOService *service = [[XMLIOService alloc] initWithNetService:sender];
		[self.services addObject:service];
		if ([self.delegate respondsToSelector:@selector(JMRINetServiceBrowser:didFindService:moreComing:)]) {
			[self.delegate JMRINetServiceBrowser:self didFindService:service moreComing:_searching];
		}
	}
}

@end
