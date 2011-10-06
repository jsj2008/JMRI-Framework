/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOServiceHelper.h
//  JMRI Framework
//
//  Created by Randall Wood on 14/5/2011.
//

#import <Foundation/Foundation.h>

@class XMLIOObject;
@class XMLIOThrottle;
@class XMLIOService;

@interface XMLIOServiceHelper : NSOperation <NSXMLParserDelegate> {

	XMLIOService *delegate_;
	NSMutableData* connectionData;
	NSMutableDictionary* items;
    XMLIOObject* rootElement;
    XMLIOObject* currentElement;
	NSUInteger operation_;
	NSString *type_;
	NSString *name_;
	NSURLRequest *request_;
    BOOL isExecuting_;
    BOOL isFinished_;

}

- (id)initWithDelegate:(id)delegate
         withOperation:(NSUInteger)operation
           withRequest:(NSURLRequest *)request
              withType:(NSString *)type
              withName:(NSString *)name;

@property (retain) XMLIOService *delegate;
@property NSUInteger operation;
@property (retain) NSString *name;
@property (retain) NSString *type;
@property (retain) NSURLRequest *request;

@end

@protocol XMLIOServiceHelperDelegate

#pragma mark Required Methods

@required
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didFailWithError:(NSError *)error;
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didConnectWithRequest:(NSURLRequest *)request;

#pragma mark Optional Methods

@optional
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type;
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didReadItem:(XMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didWriteItem:(XMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)XMLIOServiceHelperDidFinishLoading:(XMLIOServiceHelper *)helper;
- (void)XMLIOServiceHelper:(XMLIOServiceHelper *)helper didGetThrottle:(XMLIOThrottle *)throttle atAddress:(NSUInteger)address;

@end