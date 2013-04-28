/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOServiceHelper.m
//  JMRI Framework
//
//  Created by Randall Wood on 14/5/2011.
//

#import "XMLIOServiceHelper.h"
#import "XMLIOService.h"
#import "XMLIOFunction.h"
#import "XMLIOItem.h"
#import "XMLIORoster.h"
#import "XMLIOThrottle.h"
#import "XMLIOMetadata.h"
#import "JMRIConstants.h"

// XMLIO Types
NSString *const XMLIOXMLXMLIO = @"xmlio";
NSString *const XMLIOXMLItem = @"item";
NSString *const XMLIOXMLThrottle = @"throttle";

// XMLIO Roster function attribute names that are properties of XMLIOFunction objects
NSString *const XMLIOXMLFunction = @"function";
NSString *const XMLIORosterFunctionLabel = @"label";
NSString *const XMLIORosterFunctionLockable = @"lockable";

@implementation XMLIOServiceHelper

#pragma mark - Properties

@synthesize delegate = delegate_;
@synthesize name = name_;
@synthesize operation = operation_;
@synthesize request = request_;
@synthesize type = type_;
@synthesize connectionData = connectionData;

- (id)initWithDelegate:(id)delegate withOperation:(NSUInteger)operation withRequest:(NSURLRequest *)request withType:(NSString *)type withName:(NSString *)name {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.name = [name copy];
        self.operation = operation;
        self.request = [request copy];
        self.type = [type copy];
        isExecuting_ = NO;
        isFinished_ = NO;
    }
    return self;
}

#pragma mark - NSOperation methods

- (void)start {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    isExecuting_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    // do stuff from XMLIOService:performOperation
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:self.request delegate:self];
    if (connection) {
        if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didConnectWithRequest:)]) {
            [self.delegate XMLIOServiceHelper:self didConnectWithRequest:self.request];
        }
    } else { // failed to create NSURLConnection object
        [self.delegate XMLIOServiceHelper:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain code:1027 userInfo:nil]];
    }
}

- (void)finish {
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];    
    isExecuting_ = NO;
    isFinished_ = YES;    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return isExecuting_;
}

- (BOOL)isFinished {
    return isFinished_;
}

#pragma mark - URL Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Did receieve response");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
	if (!connectionData) {
		connectionData = [[NSMutableData alloc] init];
	}
    [connectionData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [connectionData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didFailWithError:)]) {
		[self.delegate XMLIOServiceHelper:self didFailWithError:error];
	}
	// connection is autoreleased, so ignore it.
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished loading");
	NSXMLParser *parser;
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelperDidFinishLoading:)]) {
		[self.delegate XMLIOServiceHelperDidFinishLoading:self];
	}
    parser = [[NSXMLParser alloc] initWithData:connectionData];
	@synchronized(parser) {
		connectionData = nil;
		[parser setDelegate:self];
		[parser parse];
		parser = nil;
	}
    [self finish];
}

#pragma mark - XML parser delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if (items) {
        items = nil;
    }
    items = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	switch (self.operation) {
		case XMLIOOperationList:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didListItems:ofType:)]) {
				[self.delegate XMLIOServiceHelper:self didListItems:[items allValues] ofType:self.type];
			}
            if ([self.type isEqualToString:JMRITypeMetadata] && [self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didReadItem:withName:ofType:withValue:)] && [[items allKeys] containsObject:JMRIMetadataJMRIVersion]) {
                [self.delegate XMLIOServiceHelper:self 
                                      didReadItem:[items objectForKey:JMRIMetadataJMRIVersion]
                                         withName:JMRIMetadataJMRIVersion
                                           ofType:JMRITypeMetadata
                                        withValue:[[items objectForKey:JMRIMetadataJMRIVersion] value]];
            }
			break;
		case XMLIOOperationRead:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didReadItem:withName:ofType:withValue:)]) {
				[self.delegate XMLIOServiceHelper:self didReadItem:[items objectForKey:name_] withName:name_ ofType:type_ withValue:[[items objectForKey:name_] valueForKey:XMLIOItemValue]];
			}
			break;
		case XMLIOOperationWrite:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didWriteItem:ofType:withValue:)]) {
				[self.delegate XMLIOServiceHelper:self didWriteItem:[items objectForKey:name_] withName:name_ ofType:type_ withValue:[[items objectForKey:name_] valueForKey:XMLIOItemValue]];
			}
            break;
        case XMLIOOperationThrottle:
            if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didGetThrottle:atAddress:)]) {
                [self.delegate XMLIOServiceHelper:self didGetThrottle:[items objectForKey:name_] atAddress:[name_ integerValue]];
            }
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (rootElement == nil) {
        XMLIOObject *root = [[XMLIOObject alloc] init];
        rootElement = root;
        currentElement = root;
    } else {
        XMLIOObject *newElement;
        if ([elementName isEqualToString:JMRITypeRoster]) {
            newElement = [[XMLIORoster alloc] init];
            [(XMLIORoster *)newElement setDccAddress:[[attributeDict objectForKey:XMLIORosterDCCAddress] integerValue]];
            [(XMLIORoster *)newElement setAddressLength:[attributeDict objectForKey:XMLIORosterAddressLength]];
            [(XMLIORoster *)newElement setComment:[attributeDict objectForKey:XMLIOItemComment]];
            [(XMLIORoster *)newElement setImageFileName:[attributeDict objectForKey:XMLIORosterImageFileName]];
            [(XMLIORoster *)newElement setImageIconName:[attributeDict objectForKey:XMLIORosterImageIconName]];
            [(XMLIORoster *)newElement setMaxSpeedPct:[[attributeDict objectForKey:XMLIORosterMaxSpeedPct] floatValue]];
            [(XMLIORoster *)newElement setMfg:[attributeDict objectForKey:XMLIORosterMFG]];
            [(XMLIORoster *)newElement setModel:[attributeDict objectForKey:XMLIORosterModel]];
            [(XMLIORoster *)newElement setName:[attributeDict objectForKey:XMLIOItemName]];
            [(XMLIORoster *)newElement setRoadName:[attributeDict objectForKey:XMLIORosterRoadName]];
            [(XMLIORoster *)newElement setRoadNumber:[attributeDict objectForKey:XMLIORosterRoadNumber]];
            [(XMLIORoster *)newElement setUserName:[[NSString stringWithFormat:@"%@ %@", [attributeDict objectForKey:XMLIORosterRoadName], [attributeDict objectForKey:XMLIORosterRoadNumber]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            [(XMLIORoster *)newElement setType:JMRITypeRoster];
        } else if ([elementName isEqualToString:JMRITypeMemory] ||
                   [elementName isEqualToString:JMRITypeMetadata] ||
                   [elementName isEqualToString:JMRITypeFrame] ||
                   [elementName isEqualToString:JMRITypePanel] ||
                   [elementName isEqualToString:JMRITypePower] ||
                   [elementName isEqualToString:JMRITypeRoute] ||
                   [elementName isEqualToString:JMRITypeSensor] ||
                   [elementName isEqualToString:JMRITypeTurnout]) {
            if ([elementName isEqualToString:JMRITypeMetadata]) {
                newElement = [[XMLIOMetadata alloc] init];
            } else {
                newElement = [[XMLIOItem alloc] init];
            }
            [(XMLIOItem *)newElement setType:elementName];
            [(XMLIOItem *)newElement setName:[attributeDict objectForKey:XMLIOItemName]];
            [(XMLIOItem *)newElement setUserName:[attributeDict objectForKey:XMLIOItemUserName]];
            [(XMLIOItem *)newElement setValue:[attributeDict objectForKey:XMLIOItemValue]];
            [(XMLIOItem *)newElement setComment:[attributeDict objectForKey:XMLIOItemComment]];
            [(XMLIOItem *)newElement setInverted:[[attributeDict objectForKey:XMLIOItemInverted] isEqualToString:XMLIOBooleanYES]];
            if ([XMLIOBooleanYES isEqualToString:[attributeDict objectForKey:XMLIOItemIsNull]]) {
                [(XMLIOItem *)newElement setValue:nil];
            }
            if ([elementName isEqualToString:JMRITypeMetadata]) {
                [(XMLIOMetadata *)newElement setMajorVersion:[[attributeDict objectForKey:JMRIMetadataVersionMajor] integerValue]];
                [(XMLIOMetadata *)newElement setMinorVersion:[[attributeDict objectForKey:JMRIMetadataVersionMinor] integerValue]];
                [(XMLIOMetadata *)newElement setTestVersion:[[attributeDict objectForKey:JMRIMetadataVersionTest] integerValue]];
            }
        } else if ([elementName isEqualToString:XMLIOXMLThrottle]) {
            XMLIOThrottle *t = [self.delegate.throttles objectForKey:[attributeDict objectForKey:XMLIOThrottleAddress]];
            t.shouldSendUpdate = NO;
            t.forward = [[attributeDict objectForKey:XMLIOThrottleForward] isEqualToString:XMLIOBooleanYES];
            t.speed = [[attributeDict objectForKey:XMLIOThrottleSpeed] floatValue];
            if ([attributeDict objectForKey:XMLIOThrottleSpeedStepMode]) {
                t.speedStepMode = [[attributeDict objectForKey:XMLIOThrottleSpeedStepMode] integerValue];
            }
            [t setState:(([[attributeDict objectForKey:XMLIOThrottleF0] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive) forFunction:0];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF1] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:1];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF2] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:2];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF3] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:3];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF4] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:4];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF5] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:5];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF6] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:6];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF7] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:7];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF8] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:8];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF9] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:9];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF10] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:10];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF11] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:11];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF12] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:12];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF13] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:13];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF14] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:14];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF15] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:15];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF16] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:16];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF17] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:17];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF18] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:18];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF19] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:19];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF20] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:20];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF21] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:21];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF22] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:22];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF23] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:23];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF24] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:24];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF25] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:25];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF26] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:26];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF27] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:27];
            [t setState:([[attributeDict objectForKey:XMLIOThrottleF28] isEqualToString:XMLIOBooleanYES]) ? JMRIItemStateActive : JMRIItemStateInactive forFunction:28];
            t.shouldSendUpdate = YES;
            newElement = t;
            // its an error to have requested a throttle that does not already exist
        } else if ([elementName isEqualToString:XMLIOXMLFunction]) {
            NSUInteger i = [[[attributeDict objectForKey:XMLIOItemName] substringFromIndex:1] integerValue];
            XMLIOFunction *f = [[(XMLIORoster *)currentElement functions] objectAtIndex:i];
            f.label = [attributeDict objectForKey:XMLIORosterFunctionLabel];
            f.lockable = [[attributeDict objectForKey:XMLIORosterFunctionLockable] isEqualToString:XMLIOBooleanYES];
            newElement = [[XMLIOObject alloc] init];
        } else if ([elementName isEqualToString:XMLIOXMLItem]) {
            newElement = [[XMLIOItem alloc] init];
        } else {
            newElement = [[XMLIOObject alloc] init];
        }
        newElement.parent = currentElement;
        [currentElement.children addObject:newElement];
        currentElement = newElement;
    }
    currentElement.XMLName = elementName;
    if ([attributeDict count]) {
        [currentElement.attributes addEntriesFromDictionary:attributeDict];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (currentElement) {
        if (currentElement.parent) {
            if (rootElement == currentElement.parent) {
                if ([currentElement isKindOfClass:[XMLIOThrottle class]]) {
                    [items setObject:currentElement forKey:name_];
                } else {
                    [items setObject:currentElement forKey:[(XMLIOItem *)currentElement name]];
                }
            }
        }
        currentElement = currentElement.parent;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (currentElement) {
        if (!currentElement.text) {
            currentElement.text = string;
        } else {
            currentElement.text = [currentElement.text stringByAppendingString:string];
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didFailWithError:)]) {
        switch (parseError.code) {
            case NSXMLParserPrematureDocumentEndError: // NSXMLParserErrorDomain code 5
                [self.delegate XMLIOServiceHelper:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain code:JMRICannotCreateItem userInfo:@{@"item": self.name, @"type": self.type}]];
                break;
            default:
                NSLog(@"Error %ld, Description: %@, Line: %ld, Column: %ld",
                      (long)[parseError code],
                      [[parser parserError] localizedDescription],
                      (long)[parser lineNumber],
                      (long)[parser columnNumber]);
                [self.delegate XMLIOServiceHelper:self didFailWithError:parseError];
        }
	} else {
        NSLog(@"Error %ld, Description: %@, Line: %ld, Column: %ld",
              (long)[parseError code],
              [[parser parserError] localizedDescription],
              (long)[parser lineNumber],
              (long)[parser columnNumber]);
    }
}

@end
