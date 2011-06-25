/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIXMLIOServiceHelper.h
//  JMRI Framework
//
//  Created by Randall Wood on 14/5/2011.
//

#import <Foundation/Foundation.h>

@class JMRIXMLIOObject;

@interface JMRIXMLIOServiceHelper : NSObject <NSXMLParserDelegate> {

	id delegate;
	NSMutableData* connectionData;
	NSMutableDictionary* items;
    JMRIXMLIOObject* rootElement;
    JMRIXMLIOObject* currentElement;
	NSUInteger operation;
	NSString *type;
	NSString *name;
	NSURLRequest *request;

}

@property (retain) id delegate;
@property NSUInteger operation;
@property (retain) NSString *name;
@property (retain) NSString *type;
@property (retain) NSURLRequest *request;

@end

@protocol JMRIXMLIOServiceHelperDelegate

#pragma mark Required Methods

@required
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didListItems:(NSArray *)items ofType:(NSString *)type;
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didReadItem:(JMRIXMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOServiceHelper:(JMRIXMLIOServiceHelper *)helper didWriteItem:(JMRIXMLIOObject *)item withName:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)JMRIXMLIOServiceHelperDidFinishLoading:(JMRIXMLIOServiceHelper *)helper;

@end