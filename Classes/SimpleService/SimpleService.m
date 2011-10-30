//
//  SimpleService.m
//  JMRI Framework
//
//  Created by Randall Wood on 28/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "SimpleService.h"
#ifdef TARGET_OS_IPHONE
#import "NSStream+JMRIExtensions.h"
#endif

@interface SimpleService ()

- (void)write:(NSString *)string;
- (void)open;
- (void)close;

@end

@implementation SimpleService

- (id)initWithNetService:(NSNetService *)service {
    if ((self = [super initWithNetService:service])) {
        if ([service getInputStream:&input outputStream:&output]) {
            [self open];
        }
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithAddress:address withPort:port])) {
#ifdef TARGET_OS_IPHONE
        [NSStream getStreamsToHostNamed:address port:port inputStream:&input outputStream:&output];
#else
        [NSStream getStreamsToHost:[NSHost hostWithAddress:address] port:port inputStream:&input outputStream:&output];
#endif
        if (input != nil) {
            [self open];
        }
    }
    return self;
}

#pragma mark - Private methods

- (void)open {
    input.delegate = self;
    output.delegate = self;
    [input scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [output scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [input open];
    [output open];
}

- (void)close {
    [input close];
    [output close];
}

- (void)write:(NSString *)string {
    if ([output hasSpaceAvailable]) {
        [output write:[[string dataUsingEncoding:NSASCIIStringEncoding] bytes]
            maxLength:[string lengthOfBytesUsingEncoding:NSASCIIStringEncoding]];
    }
}

- (void)openConnection {
    [self open];
    // if we ever need to handshake - do it here
}

- (void)closeConnection {
    [self close];
    // if we ever need to send a closing message - do it here
}

#pragma mark - JMRINetService items

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    NSString *string = [NSString stringWithFormat:@"%@ %@\n\r", [type uppercaseString], name];
    [self write:string];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
    [self readItem:name ofType:type];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@\n\r", [type uppercaseString], name, [value uppercaseString]];
    [self write:string];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if (aStream == input) {
        switch (eventCode) {
            case NSStreamEventNone:
                break;
            case NSStreamEventOpenCompleted:
                break;
            case NSStreamEventHasBytesAvailable:
                
                break;
            case NSStreamEventErrorOccurred:
                break;
            case NSStreamEventEndEncountered:
                break;
            default:
                break;
        }
    } else {
        switch (eventCode) {
            case NSStreamEventNone:
                break;
            case NSStreamEventOpenCompleted:
                break;
            case NSStreamEventHasSpaceAvailable:
                break;
            case NSStreamEventErrorOccurred:
                break;
            case NSStreamEventEndEncountered:
                break;
            default:
                break;
        }
    }
}

@end
