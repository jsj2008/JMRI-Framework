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

// XMLIO Types
NSString *const XMLIOXMLXMLIO = @"xmlio";
NSString *const XMLIOXMLItem = @"item";
NSString *const XMLIOXMLThrottle = @"throttle";

// XMLIO 2.12 Roster elements that are implemented differently in the Objective-C classes
NSString *const XMLIORosterFunctionLabels = @"functionLabels";
NSString *const XMLIORosterFunctionLockables = @"functionLockables";

// XMLIO 2.13 Roster function attribute names that are properties of XMLIOFunction objects
NSString *const XMLIOXMLFunction = @"function";
NSString *const XMLIORosterFunctionLabel = @"label";
NSString *const XMLIORosterFunctionLockable = @"lockable";

@implementation XMLIOServiceHelper

#pragma mark -
#pragma mark Properties

@synthesize delegate = delegate_;
@synthesize name = name_;
@synthesize operation = operation_;
@synthesize request = request_;
@synthesize type = type_;

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

#pragma mark -
#pragma mark NSOperation methods

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
        [self.delegate XMLIOServiceHelper:self didFailWithError:[NSError errorWithDomain:@"JMRIErrorDomain" code:1027 userInfo:nil]];
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

#pragma mark -
#pragma mark URL Connection delegate

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
	if ([self.delegate logTraffic]) {
		NSLog(@"Received: %@", [NSString stringWithUTF8String:[connectionData bytes]]);
	}
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelperDidFinishLoading:)]) {
		[self.delegate XMLIOServiceHelperDidFinishLoading:self];
	}
    parser = [[NSXMLParser alloc] initWithData:connectionData];
	@synchronized(parser) {
		[connectionData release];
		connectionData = nil;
		[parser setDelegate:self];
		[parser parse];
		[parser release];
		parser = nil;
	}
    [self finish];
}

#pragma mark -
#pragma mark XML parser delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if (items) {
        [items release];
    }
    items = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"Finished parsing");
	switch (self.operation) {
		case XMLIOOperationList:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didListItems:ofType:)]) {
				[self.delegate XMLIOServiceHelper:self didListItems:[items allValues] ofType:self.type];
			}
            if ([self.type isEqualToString:XMLIOTypeMetadata] && [self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didReadItem:withName:ofType:withValue:)] && [[items allKeys] containsObject:XMLIOMetadataJMRIVersion]) {
                [self.delegate XMLIOServiceHelper:self 
                                      didReadItem:[items objectForKey:XMLIOMetadataJMRIVersion]
                                         withName:XMLIOMetadataJMRIVersion
                                           ofType:XMLIOTypeMetadata
                                        withValue:[[items objectForKey:XMLIOMetadataJMRIVersion] value]];
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
        currentElement = [root retain];
        [root release];
    } else {
        XMLIOObject *newElement;
        if ([elementName isEqualToString:XMLIOTypeRoster]) {
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
            [(XMLIORoster *)newElement setType:XMLIOTypeRoster];
        } else if ([elementName isEqualToString:XMLIOTypeMemory] ||
                   [elementName isEqualToString:XMLIOTypeMetadata] ||
                   [elementName isEqualToString:XMLIOTypePanel] ||
                   [elementName isEqualToString:XMLIOTypePower] ||
                   [elementName isEqualToString:XMLIOTypeRoute] ||
                   [elementName isEqualToString:XMLIOTypeSensor] ||
                   [elementName isEqualToString:XMLIOTypeTurnout]) {
            if ([elementName isEqualToString:XMLIOTypeMetadata]) {
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
            if ([elementName isEqualToString:XMLIOTypeMetadata]) {
                [(XMLIOMetadata *)newElement setMajorVersion:[[attributeDict objectForKey:XMLIOMetadataVersionMajor] integerValue]];
                [(XMLIOMetadata *)newElement setMinorVersion:[[attributeDict objectForKey:XMLIOMetadataVersionMinor] integerValue]];
                [(XMLIOMetadata *)newElement setTestVersion:[[attributeDict objectForKey:XMLIOMetadataVersionTest] integerValue]];
            }
        } else if ([elementName isEqualToString:XMLIOXMLThrottle]) {
            if (self.delegate.useAttributeProtocol) {
                XMLIOThrottle *t = [self.delegate.throttles objectForKey:[attributeDict objectForKey:XMLIOThrottleAddress]];
                t.shouldSendUpdate = NO;
                t.forward = [[attributeDict objectForKey:XMLIOThrottleForward] isEqualToString:XMLIOBooleanYES];
                t.speed = [[attributeDict objectForKey:XMLIOThrottleSpeed] floatValue];
                if ([attributeDict objectForKey:XMLIOThrottleSpeedStepMode]) {
                    t.speedStepMode = [[attributeDict objectForKey:XMLIOThrottleSpeedStepMode] integerValue];
                }
                [t setState:(([[attributeDict objectForKey:XMLIOThrottleF0] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive) forFunction:0];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF1] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:1];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF2] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:2];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF3] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:3];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF4] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:4];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF5] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:5];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF6] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:6];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF7] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:7];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF8] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:8];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF9] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:9];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF10] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:10];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF11] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:11];
                [t setState:([[attributeDict objectForKey:XMLIOThrottleF12] isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:12];
                t.shouldSendUpdate = YES;
                newElement = t;
                // its an error to have requested a throttle that does not already exist
            } else {
                newElement = [[XMLIOThrottle alloc] init];
            }
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
        [newElement release];
    }
    currentElement.XMLName = elementName;
    if ([attributeDict count]) {
        [currentElement.attributes addEntriesFromDictionary:attributeDict];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self.delegate.useAttributeProtocol) {
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
    } else { // the rest of this method supports JMRI 2.12
        if (currentElement) {
            if (currentElement.parent) {
                XMLIOObject *parent;
                XMLIOFunction *f;
                if ([currentElement.parent isMemberOfClass:[XMLIOThrottle class]]) {
                    parent = (XMLIOThrottle *)currentElement.parent;
                } else {
                    parent = (XMLIOItem *)currentElement.parent;
                }
                if (currentElement.parent != rootElement) {
                    if (self.delegate.useAttributeProtocol) {
                    } else {
                        if ([currentElement.parent isKindOfClass:[XMLIOItem class]] ||
                            [currentElement.parent isKindOfClass:[XMLIOThrottle class]]) {
                            if ([currentElement.XMLName isEqualToString:XMLIORosterDCCAddress]) {
                                [(XMLIORoster *)parent setDccAddress:[currentElement.text integerValue]];
                            } else if ([currentElement.XMLName isEqualToString:XMLIORosterRoadName]) {
                                [(XMLIORoster *)parent setRoadName:currentElement.text];
                            } else if ([currentElement.XMLName isEqualToString:XMLIORosterRoadNumber]) {
                                [(XMLIORoster *)parent setRoadNumber:currentElement.text];
                            } else if ([currentElement.XMLName isEqualToString:XMLIORosterMaxSpeedPct]) {
                                [(XMLIORoster *)parent setMaxSpeedPct:[currentElement.text floatValue]];
                            } else if ([currentElement.XMLName isEqualToString:XMLIOItemInverted]) {
                                [(XMLIOItem *)parent setInverted:[currentElement.text isEqualToString:XMLIOBooleanYES]];
                            } else if ([currentElement.XMLName isEqualToString:XMLIOThrottleAddress]) {
                                [(XMLIOThrottle *)parent setAddress:[currentElement.text integerValue]];
                            } else if ([currentElement.XMLName isEqualToString:XMLIOThrottleForward]) {
                                [(XMLIOThrottle *)parent setForward:[currentElement.text isEqualToString:XMLIOBooleanYES]];
                            } else if ([[currentElement.XMLName substringToIndex:1] isEqualToString:@"F"]) {
                                [(XMLIOThrottle *)parent setState:([currentElement.text isEqualToString:XMLIOBooleanYES]) ? XMLIOItemStateActive : XMLIOItemStateInactive forFunction:[[elementName substringFromIndex:1] integerValue]];
                            } else if ([currentElement.XMLName isEqualToString:XMLIOMetadataVersionMajor] ||
                                       [currentElement.XMLName isEqualToString:XMLIOMetadataVersionMinor] ||
                                       [currentElement.XMLName isEqualToString:XMLIOMetadataVersionTest]) {
                                // Do not attmept to read version specifics unless using
                                // attribute protocol
                            } else if (![currentElement.XMLName isEqualToString:XMLIORosterFunctionLabels] &&
                                       ![currentElement.XMLName isEqualToString:XMLIORosterFunctionLockables] &&
                                       ![currentElement.XMLName isEqualToString:XMLIOXMLFunction]) {
                                [parent setValue:currentElement.text forKey:elementName];
                            }
                        } else if ([parent.XMLName isEqualToString:XMLIORosterFunctionLabels] ||
                                   [parent.XMLName isEqualToString:XMLIORosterFunctionLockables]) {
                            XMLIORoster *roster = (XMLIORoster *)parent.parent;
                            NSUInteger i = [[elementName substringFromIndex:1] integerValue];
                            f = [roster.functions objectAtIndex:i];
                            if ([parent.XMLName isEqualToString:XMLIORosterFunctionLabels]) {
                                f.label = currentElement.text;
                            } else {
                                f.lockable = [currentElement.text isEqualToString:XMLIOBooleanYES];
                            }
                        }
                    }
                }
                if ([currentElement isMemberOfClass:[XMLIOItem class]] && [[(XMLIOItem *)currentElement type] isEqualToString:XMLIOTypeRoster]) {
                    XMLIORoster *rosterElement = [[XMLIORoster alloc] initWithItem:(XMLIOItem *)currentElement];
                    rosterElement.children = currentElement.children;
                    rosterElement.parent = currentElement.parent;
                    [rosterElement.parent.children addObject:rosterElement];
                    [rosterElement.parent.children removeObject:currentElement];
                    [currentElement release];
                    currentElement = rosterElement;
                    [rosterElement release];
                }
                if ([currentElement isMemberOfClass:[XMLIOThrottle class]]) {
                    XMLIOThrottle *throttleElement = [self.delegate.throttles objectForKey:[[NSNumber numberWithInteger:[(XMLIOThrottle *)currentElement address]] stringValue]];
                    throttleElement.children = currentElement.children;
                    throttleElement.parent = currentElement.parent;
                    [throttleElement.parent.children addObject:throttleElement];
                    [throttleElement.parent.children removeObject:currentElement];
                    [throttleElement updateFromThrottle:(XMLIOThrottle *)currentElement];
                    currentElement = throttleElement;
                }
                if (rootElement == currentElement.parent) {
                    if ([currentElement isKindOfClass:[XMLIOThrottle class]]) {
                        [items setObject:currentElement forKey:name_];
                    } else {
                        [items setObject:currentElement forKey:[(XMLIOItem *)currentElement name]];
                    }
                }
            }
            if ([currentElement isMemberOfClass:[XMLIORoster class]]) {
                [(XMLIORoster *)currentElement setUserName:[[[(XMLIORoster *)currentElement roadName] stringByAppendingFormat:@" %@", [(XMLIORoster *)currentElement roadNumber], nil] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            currentElement = currentElement.parent;
        }
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
    NSLog(@"Error %ld, Description: %@, Line: %ld, Column: %ld", 
		  (long)[parseError code],
		  [[parser parserError] localizedDescription],
		  (long)[parser lineNumber],
		  (long)[parser columnNumber]);
	if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didFailWithError:)]) {
		[self.delegate XMLIOServiceHelper:self didFailWithError:parseError];
	}
}

@end
