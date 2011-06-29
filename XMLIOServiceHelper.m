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

// XMLIO Types
NSString *const XMLIOXMLXMLIO = @"xmlio";
NSString *const XMLIOXMLItem = @"item";
NSString *const XMLIOXMLThrottle = @"throttle";

// XMLIO Roster elements that are implemented differently in the Objective-C classes
NSString *const XMLIORosterFunctionLabels = @"functionLabels";
NSString *const XMLIORosterFunctionLockables = @"functionLockables";

// Javaisms
NSString *const JavaYES = @"true"; // java.lang.Boolean.toString returns "true" for YES
NSString *const JavaNO = @"false"; // java.lang.Boolean.toString returns "false" for NO

@implementation XMLIOServiceHelper

#pragma mark -
#pragma mark Properties

@synthesize delegate;
@synthesize name;
@synthesize operation;
@synthesize request;
@synthesize type;

#pragma mark -
#pragma mark URL Connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
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
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
	switch (operation) {
		case XMLIOOperationList:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didListItems:ofType:)]) {
				[self.delegate XMLIOServiceHelper:self didListItems:[items allValues] ofType:type];
			}
			break;
		case XMLIOOperationRead:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didReadItem:withName:ofType:withValue:)]) {
				[self.delegate XMLIOServiceHelper:self didReadItem:[items objectForKey:name] withName:name ofType:type withValue:[[items objectForKey:name] valueForKey:XMLIOItemValue]];
			}
			break;
		case XMLIOOperationWrite:
			if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didWriteItem:ofType:withValue:)]) {
				[self.delegate XMLIOServiceHelper:self didWriteItem:[items objectForKey:name] withName:name ofType:type withValue:[[items objectForKey:name] valueForKey:XMLIOItemValue]];
			}
            break;
        case XMLIOOperationThrottle:
            if ([self.delegate respondsToSelector:@selector(XMLIOServiceHelper:didGetThrottle:atAddress:)]) {
                [self.delegate XMLIOServiceHelper:self didGetThrottle:[items objectForKey:name] atAddress:[name integerValue]];
            }
			break;
	}
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (rootElement == nil) {
        XMLIOObject *root = [[XMLIOObject alloc] init];
        rootElement = root;
        currentElement = root;
        [root release];
    } else {
        XMLIOObject *newElement;
        if ([elementName isEqualToString:XMLIOXMLItem]) {
            newElement = [[XMLIOItem alloc] init];
        } else if ([elementName isEqualToString:XMLIOXMLThrottle]) {
            newElement = [[XMLIOThrottle alloc] init];
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
    if (currentElement) {
        if (currentElement.parent) {
            XMLIOObject *parent;
            XMLIOFunction *f;
            if ([currentElement.parent isMemberOfClass:[XMLIOThrottle class]]) {
                parent = (XMLIOThrottle *)currentElement.parent;
            } else {
                parent = (XMLIOItem *)currentElement.parent;
            }
            if ([currentElement.parent isKindOfClass:[XMLIOObject class]]) {
                if ([currentElement.XMLName isEqualToString:XMLIORosterDCCAddress]) {
                    [(XMLIORoster *)parent setDccAddress:[currentElement.text integerValue]];
                } else if ([currentElement.XMLName isEqualToString:XMLIORosterRoadNumber]) {
                    [(XMLIORoster *)parent setRoadNumber:[currentElement.text integerValue]];
                } else if ([currentElement.XMLName isEqualToString:XMLIORosterMaxSpeedPct]) {
                    [(XMLIORoster *)parent setMaxSpeedPct:[currentElement.text floatValue]];
                } else if ([currentElement.XMLName isEqualToString:XMLIOItemInverted]) {
                    [(XMLIOItem *)parent setInverted:[currentElement.text isEqualToString:JavaYES]];
                } else if ([currentElement.XMLName isEqualToString:XMLIOThrottleAddress]) {
                    [(XMLIOThrottle *)parent setAddress:[currentElement.text integerValue]];
                } else if ([[currentElement.XMLName substringToIndex:1] isEqualToString:@"F"]) {
                    f = [[XMLIOFunction alloc] initWithFunctionIdentifier:[[currentElement.XMLName substringFromIndex:1] integerValue]];
                    [(XMLIOThrottle *)parent setValue:f forKey:currentElement.XMLName];
                    [f release];
                } else if (![currentElement.XMLName isEqualToString:XMLIORosterFunctionLabels] &&
                    ![currentElement.XMLName isEqualToString:XMLIORosterFunctionLockables]) {
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
                    f.lockable = [currentElement.text isEqualToString:JavaYES];
                }
             }
            if (rootElement == currentElement.parent) {
                if ([currentElement isKindOfClass:[XMLIOThrottle class]]) {
                    [items setObject:currentElement forKey:name];
                } else {
                    [items setObject:currentElement forKey:[(XMLIOItem *)currentElement name]];
                }
            }
        }
        if ([currentElement isMemberOfClass:[XMLIORoster class]]) {
            [(XMLIORoster *)currentElement setUserName:[[(XMLIORoster *)currentElement roadName] stringByAppendingFormat:@" %u", [(XMLIORoster *)currentElement roadNumber], nil]];
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
