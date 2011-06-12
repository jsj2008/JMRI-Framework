//
//  JMRIXMLIOServiceHelper.m
//  JMRI Framework
//
//  Created by Randall Wood on 14/5/2011.
//  Copyright 2011 Alexandria Software. All rights reserved.
//

#import "JMRIXMLIOServiceHelper.h"
#import "JMRIXMLIOService.h"
#import "JMRIXMLIOItem.h"
#import "JMRIXMLIOThrottle.h"

NSString *const JMRIXMLIOXMLXMLIO = @"xmlio";
NSString *const JMRIXMLIOXMLItem = @"item";
NSString *const JMRIXMLIOXMLThrottle = @"throttle";

@implementation JMRIXMLIOServiceHelper

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
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelper:didFailWithError:)]) {
		[self.delegate JMRIXMLIOServiceHelper:self didFailWithError:error];
	}
	// connection is autoreleased, so ignore it.
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSXMLParser *parser;
	if ([self.delegate logTraffic]) {
		NSLog(@"Received: %@", [NSString stringWithUTF8String:[connectionData bytes]]);
	}
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelperDidFinishLoading:)]) {
		[self.delegate JMRIXMLIOServiceHelperDidFinishLoading:self];
	}
	@synchronized(parser) {
		parser = [[NSXMLParser alloc] initWithData:connectionData];
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

- (void)parserDidEndDocument:(NSXMLParser *)parser {
	switch (operation) {
		case JMRIXMLIOOperationList:
			if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelper:didListItems:ofType:)]) {
				[self.delegate JMRIXMLIOServiceHelper:self didListItems:[items allValues] ofType:type];
			}
			break;
		case JMRIXMLIOOperationRead:
			if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelper:didReadItem:withName:ofType:withValue:)]) {
				[self.delegate JMRIXMLIOServiceHelper:self didReadItem:[items objectForKey:name] withName:name ofType:type withValue:[[items objectForKey:name] valueForKey:JMRIXMLIOItemValue]];
			}
			break;
		case JMRIXMLIOOperationWrite:
			if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelper:didWriteItem:ofType:withValue:)]) {
				[self.delegate JMRIXMLIOServiceHelper:self didWriteItem:[items objectForKey:name] withName:name ofType:type withValue:[[items objectForKey:name] valueForKey:JMRIXMLIOItemValue]];
			}
			break;
	}
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
	if (items) {
		[items release];
	}
	items = [[NSMutableDictionary alloc] initWithCapacity:0];		
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	if ([elementName isEqualToString:JMRIXMLIOXMLItem]) {
		if (currentItem) {
			[currentItem release];
		}
		currentItem = [[JMRIXMLIOItem alloc] init];
	} else if ([elementName isEqualToString:JMRIXMLIOXMLThrottle]) {
		if (currentItem) {
			[currentItem release];
		}
		currentItem = [[JMRIXMLIOThrottle alloc] init];
	} else {
		[currentItem setValue:nil forKey:elementName];
		currentValue = [[NSMutableString alloc] initWithCapacity:0];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([elementName isEqualToString:JMRIXMLIOXMLXMLIO]) {
	} else if ([elementName isEqualToString:JMRIXMLIOXMLItem]) {
		[items setValue:currentItem forKey:[currentItem valueForKey:JMRIXMLIOItemName]];
		[currentItem release];
		currentItem = nil;
	} else if ([elementName isEqualToString:JMRIXMLIOXMLItem]) {
		[items setValue:currentItem forKey:[currentItem valueForKey:JMRIXMLIOThrottleAddress]];
		[currentItem release];
		currentItem = nil;
	} else {
		if ([currentValue length] > 0) {
			[currentItem setValue:currentValue forKey:elementName];
		}
		[currentValue release];
		currentValue = nil;
	}
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (currentValue) {
		[currentValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"Error %i, Description: %@, Line: %i, Column: %i", 
		  [parseError code],
		  [[parser parserError] localizedDescription],
		  [parser lineNumber],
		  [parser columnNumber]);
	if ([self.delegate respondsToSelector:@selector(JMRIXMLIOServiceHelper:didFailWithError:)]) {
		[self.delegate JMRIXMLIOServiceHelper:self didFailWithError:parseError];
	}
}

@end
