//
//  SimpleService.m
//  JMRI Framework
//
//  Created by Randall Wood on 28/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "SimpleService.h"
#import "JMRIService.h"
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
        serviceType = JMRIServiceSimple;
        NSInputStream* is = [[NSInputStream alloc] init];
        NSOutputStream* os = [[NSOutputStream alloc] init];
        if ([service getInputStream:&is outputStream:&os]) {
            input = is;
            output = os;
            [self open];
        }
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithAddress:address withPort:port])) {
        serviceType = JMRIServiceSimple;
        NSInputStream* is = [[NSInputStream alloc] init];
        NSOutputStream* os = [[NSOutputStream alloc] init];
#ifdef TARGET_OS_IPHONE
        [NSStream getStreamsToHostNamed:address port:port inputStream:&is outputStream:&os];
#else
        [NSStream getStreamsToHost:[NSHost hostWithAddress:address] port:port inputStream:&is outputStream:&os];
#endif
        if (is != nil) {
            input = is;
            output = os;
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
    // if we ever need to send a closing message - do it here
    [self close];
}

#pragma mark - JMRINetService items

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    NSString *string = [NSString stringWithFormat:@"%@ %@\n", [type uppercaseString], name];
    [self write:string];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
    [self readItem:name ofType:type];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    NSString *string = [NSString stringWithFormat:@"%@ %@ %@\n", [type uppercaseString], name, [value uppercaseString]];
    [self write:string];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    NSMutableData *data;
    uint8_t buf[1024];
    unsigned int len = 0;
    if (aStream == input) {
        switch (eventCode) {
            case NSStreamEventNone:
                break;
            case NSStreamEventOpenCompleted:
                break;
            case NSStreamEventHasBytesAvailable:
                len = [(NSInputStream *)aStream read:buf maxLength:1024];
                if (len) {    
                    data = [NSData dataWithBytes:(const void *)buf length:len];
                    [data appendBytes:(const void *)buf length:len];
                    NSString *str = [NSString stringWithUTF8String:[data bytes]];
                    NSLog(@"%@", str);
                } else {
                    NSLog(@"No data.");
                }
                data = nil;
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
