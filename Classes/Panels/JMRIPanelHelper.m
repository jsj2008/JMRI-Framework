//
//  JMRIPanelHelper.m
//  JMRI Framework
//
//  Created by Randall Wood on 4/8/2012.
//
//

#import "JMRIPanelHelper.h"
#import "JMRIPanel.h"
#import "XMLPanelImage.h"
#import "XMLIOService.h"
#import "JMRIService.h"
#import "JMRISensor.h"
#import "JMRISignalHead.h"
#import "JMRITurnout.h"
#import "JMRIPanelImage.h"

// entities
NSString *const JMRIPanelIcon = @"icon";
NSString *const JMRIPanelIconMaps = @"iconmaps";
NSString *const JMRIPanelIcons = @"icons";
NSString *const JMRIPanelRotation = @"rotation";
// item states
NSString *const JMRIPanelStateActive = @"active";
NSString *const JMRIPanelStateClosed = @"closed";
NSString *const JMRIPanelStateInactive = @"inactive";
NSString *const JMRIPanelStateInconsistent = @"inconsistent";
NSString *const JMRIPanelStateThrown = @"thrown";
NSString *const JMRIPanelStateUnknown = @"unknown";
// signal aspects
NSString *const JMRIPanelSignalFlashYellow = @"flashyellow";
NSString *const JMRIPanelSignalGreen = @"green";
NSString *const JMRIPanelSignalRed = @"red";
NSString *const JMRIPanelSignalYellow = @"yellow";
NSString *const JMRIPanelSignalDark = @"dark";
NSString *const JMRIPanelSignalFlashGreen = @"flashgreen";
NSString *const JMRIPanelSignalFlashLunar = @"flashlunar";
NSString *const JMRIPanelSignalFlashRed = @"flashred";
NSString *const JMRIPanelSignalHeld = @"held";
NSString *const JMRIPanelSignalLunar = @"lunar";

@implementation JMRIPanelHelper

- (id)initWithDelegate:(id)delegate withRequest:(NSURLRequest *)request {
    if ((self = [super init])) {
        self.delegate = delegate;
        self.request = request;
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
        if ([self.delegate respondsToSelector:@selector(JMRIPanelHelper:didConnectWithRequest:)]) {
            [self.delegate JMRIPanelHelper:self didConnectWithRequest:self.request];
        }
    } else { // failed to create NSURLConnection object
        [self.delegate JMRIPanelHelper:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain code:1027 userInfo:nil]];
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
	if ([self.delegate respondsToSelector:@selector(JMRIPanelHelper:didFailWithError:)]) {
		[self.delegate JMRIPanelHelper:self didFailWithError:error];
	}
	// connection is autoreleased, so ignore it.
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Finished loading");
	NSXMLParser *parser;
	if ([self.delegate respondsToSelector:@selector(JMRIPanelHelperDidFinishLoading:)]) {
		[self.delegate JMRIPanelHelperDidFinishLoading:self];
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

#pragma mark - XMLNode handlers

- (JMRIPanelItem *)itemForXMLObject:(XMLPanelObject *)object {
    JMRIPanelItem *item = [[JMRIPanelItem alloc] init];
    item.javaClass = [object.attributes valueForKey:@"class"];
    item.position = CGPointMake([[object.attributes valueForKey:@"x"] floatValue], [[object.attributes valueForKey:@"y"] floatValue]);
    item.positionable = [[[object.attributes valueForKey:@"positionable"] stringValue] boolValue];
    item.forceControlOff = [[[object.attributes valueForKey:@"x"] stringValue] boolValue];
    item.hidden = [[[object.attributes valueForKey:@"x"] stringValue] boolValue];
    item.showTooltip = [[[object.attributes valueForKey:@"x"] stringValue] boolValue];
    item.momentary = [[[object.attributes valueForKey:@"x"] stringValue] boolValue];
    item.icon = [[[object.attributes valueForKey:@"x"] stringValue] boolValue];
    item.level = [[object.attributes valueForKey:@"level"] integerValue];
    if ([object.XMLName isEqualToString:JMRIPanelSensorIcon]) {
        return [self sensor:item withXML:object];
    } else if ([object.XMLName isEqualToString:JMRIPanelSignalHeadIcon]) {
        return [self signalHead:item withXML:object];
    } else if ([object.XMLName isEqualToString:JMRIPanelTurnoutIcon]) {
        return [self turnout:item withXML:object];
    } else if ([object.XMLName isEqualToString:JMRIPanelPositionableLabel]) {
        return [self positionableLabel:item withXML:object];
    }
    return nil;
}

- (JMRIPanelItem *)positionableLabel:(JMRIPanelItem *)item withXML:(XMLPanelObject *)object {
    for (XMLPanelObject *child in object.children) {
        if ([child.XMLName isEqualToString:@"icon"]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:NSNotFound] stringValue]];
        }
    }
    return item;
}

- (JMRIPanelItem *)sensor:(JMRIPanelItem *)item withXML:(XMLPanelObject *)object {
    JMRISensor *sensor = [self.delegate.service.sensors objectForKey:[object.attributes valueForKey:JMRITypeSensor]];
    if (!sensor) {
        sensor = [[JMRISensor alloc] initWithName:[[object.attributes valueForKey:JMRITypeSensor] stringValue] withService:self.delegate.service];
        [self.delegate.service.sensors setValue:sensor forKey:sensor.name];
        [sensor query];
    }
    item.item = sensor;
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(itemDidChangeState:) name:@"changedState" object:item.item];
    for (XMLPanelObject *child in object.children) {
        if ([child.XMLName isEqualToString:JMRIPanelStateActive]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateActive] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelStateInactive]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateInactive] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelStateUnknown]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateUnknown] stringValue]];
        }
    }
    return item;
}

- (JMRIPanelItem *)signalHead:(JMRIPanelItem *)item withXML:(XMLPanelObject *)object {
    JMRISignalHead *signalHead = [self.delegate.service.signalHeads objectForKey:[object.attributes valueForKey:@"signalhead"]];
    if (!signalHead) {
        signalHead = [[JMRISignalHead alloc] initWithName:[[object.attributes valueForKey:@"signalhead"] stringValue] withService:self.delegate.service];
        [self.delegate.service.signalHeads setValue:signalHead forKey:signalHead.name];
        [signalHead query];
    }
    item.item = signalHead;
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(itemDidChangeState:) name:@"changedState" object:item.item];
    for (XMLPanelObject *child in object.children) {
        if ([child.XMLName isEqualToString:JMRIPanelSignalDark]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceDark] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalFlashGreen]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceFlashGreen] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalFlashLunar]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceFlashLunar] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalFlashRed]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceFlashRed] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalFlashYellow]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceFlashYellow] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalGreen]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceGreen] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalLunar]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceLunar] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalRed]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceRed] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelSignalYellow]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRISignalAppearanceYellow] stringValue]];
        }
    }
    return item;
}

- (JMRIPanelItem *)turnout:(JMRIPanelItem *)item withXML:(XMLPanelObject *)object {
    JMRITurnout *turnout = [self.delegate.service.turnouts objectForKey:[object.attributes valueForKey:JMRITypeTurnout]];
    if (!turnout) {
        turnout = [[JMRITurnout alloc] initWithName:[[object.attributes valueForKey:JMRITypeTurnout] stringValue] withService:self.delegate.service];
        [self.delegate.service.sensors setValue:turnout forKey:turnout.name];
        [turnout query];
    }
    item.item = turnout;
    [[NSNotificationCenter defaultCenter] addObserver:item selector:@selector(itemDidChangeState:) name:@"changedState" object:item.item];
    for (XMLPanelObject *child in object.children) {
        if ([child.XMLName isEqualToString:JMRIPanelStateThrown]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateThrown] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelStateClosed]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateClosed] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelStateInconsistent]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateInconsistent] stringValue]];
        } else if ([child.XMLName isEqualToString:JMRIPanelStateUnknown]) {
            [item.states setValue:[self imageForObject:child] forKey:[[NSNumber numberWithInteger:JMRIItemStateUnknown] stringValue]];
        }
    }
    return item;
}

- (JMRIPanelImage *)imageForObject:(XMLPanelObject *)object {
    JMRIPanelImage *image = [[JMRIPanelImage alloc] initWithPanel:self.delegate withURL:[NSURL URLWithString:[[object.attributes valueForKey:@"url"] stringValue]]];
    image.rotation = object.rotation;
    image.scale = [[object.attributes valueForKey:@"scale"] floatValue];
    return image;
}

#pragma mark - XML parser delegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    if (items) {
        items = nil;
    }
    items = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.delegate.height = rootElement.height;
    self.delegate.width = rootElement.width;
    if ([self.delegate respondsToSelector:@selector(JMRIPanelHelper:didReadItem:)]) {
        for (JMRIPanelItem *i in items) {
            [self.delegate JMRIPanelHelper:self didReadItem:i];
        }
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (rootElement == nil) {
        XMLPanelObject *root = [[XMLPanelObject alloc] init];
        rootElement = root;
        currentElement = root;
    } else {
        XMLPanelObject *newElement;
        if ([elementName isEqualToString:JMRIPanelIcon] ||
            [elementName isEqualToString:JMRIPanelStateActive] ||
            [elementName isEqualToString:JMRIPanelStateClosed] ||
            [elementName isEqualToString:JMRIPanelStateInactive] ||
            [elementName isEqualToString:JMRIPanelStateInconsistent] ||
            [elementName isEqualToString:JMRIPanelStateThrown] ||
            [elementName isEqualToString:JMRIPanelStateUnknown] ||
            [elementName isEqualToString:JMRIPanelSignalDark] ||
            [elementName isEqualToString:JMRIPanelSignalFlashGreen] ||
            [elementName isEqualToString:JMRIPanelSignalFlashLunar] ||
            [elementName isEqualToString:JMRIPanelSignalFlashRed] ||
            [elementName isEqualToString:JMRIPanelSignalFlashYellow] ||
            [elementName isEqualToString:JMRIPanelSignalGreen] ||
            [elementName isEqualToString:JMRIPanelSignalHeld] ||
            [elementName isEqualToString:JMRIPanelSignalLunar] ||
            [elementName isEqualToString:JMRIPanelSignalRed] ||
            [elementName isEqualToString:JMRIPanelSignalYellow]) {
            newElement = [[XMLPanelImage alloc] init];
            ((XMLPanelImage *)newElement).name = elementName;
            ((XMLPanelImage *)newElement).degrees = [[attributeDict objectForKey:@"degrees"] floatValue];
            ((XMLPanelImage *)newElement).scale = [[attributeDict objectForKey:@"scale"] floatValue];
            ((XMLPanelImage *)newElement).url = [NSURL URLWithString:[attributeDict objectForKey:@"url"]];
        } else if ([elementName isEqualToString:JMRIPanelSensorIcon] ||
            [elementName isEqualToString:JMRIPanelPositionableLabel] ||
            [elementName isEqualToString:JMRIPanelSignalHeadIcon] ||
            [elementName isEqualToString:JMRIPanelTurnoutIcon]) {
            newElement = [[XMLPanelObject alloc] init];
            ((XMLPanelObject *)newElement).type = elementName;
            ((XMLPanelObject *)newElement).height = [[attributeDict objectForKey:@"height"] integerValue];
            ((XMLPanelObject *)newElement).width = [[attributeDict objectForKey:@"width"] integerValue];
            if ([elementName isEqualToString:JMRIPanelSensorIcon]) {
                ((XMLPanelObject *)newElement).item = [[attributeDict objectForKey:JMRITypeSensor] stringValue];
            } else if ([elementName isEqualToString:JMRIPanelSignalHeadIcon]) {
                ((XMLPanelObject *)newElement).item = [[attributeDict objectForKey:@"signalhead"] stringValue];
            } else if ([elementName isEqualToString:JMRIPanelTurnoutIcon]) {
                ((XMLPanelObject *)newElement).item = [[attributeDict objectForKey:JMRITypeTurnout] stringValue];
            }
        } else {
            newElement = [[XMLPanelObject alloc] init];
        }
        ((XMLPanelObject *)newElement).type = elementName;
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
                if ([self.delegate respondsToSelector:@selector(JMRIPanelHelper:didReadItem:)]) {
                    [self.delegate JMRIPanelHelper:self didReadItem:[self itemForXMLObject:currentElement]];
                }
            } else if ([elementName isEqualToString:JMRIPanelRotation]) {
                ((XMLPanelObject *)currentElement.parent).rotation = [currentElement.text integerValue];
            }
        }
        currentElement = (XMLPanelObject *)currentElement.parent;
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
	if ([self.delegate respondsToSelector:@selector(JMRIPanelHelper:didFailWithError:)]) {
		[self.delegate JMRIPanelHelper:self didFailWithError:parseError];
	}
}

@end
