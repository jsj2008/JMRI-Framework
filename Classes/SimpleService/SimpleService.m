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

- (void)open;
- (void)close;
- (void)error:(NSError *)error;

@end

@implementation SimpleService

- (id)initWithNetService:(NSNetService *)service {
    if ((self = [super initWithNetService:service])) {
        serviceType = JMRIServiceSimple;
        NSInputStream* is;
        NSOutputStream* os;
        if ([service getInputStream:&is outputStream:&os]) {
            inputStream = is;
            outputStream = os;
            [self open];
        }
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithAddress:address withPort:port])) {
        serviceType = JMRIServiceSimple;
        NSInputStream* is;
        NSOutputStream* os;
#if TARGET_OS_IPHONE
        [NSStream getStreamsToHostNamed:address port:port inputStream:&is outputStream:&os];
#else
        [NSStream getStreamsToHost:[NSHost hostWithAddress:address] port:port inputStream:&is outputStream:&os];
#endif
        if (is != nil) {
            inputStream = is;
            outputStream = os;
            [self open];
        } else {
            [self error:[[NSError alloc] initWithDomain:JMRIServiceSimple code:1 userInfo:nil]];
        }
    }
    return self;
}

#pragma mark - Private methods

- (void)open {
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)close {
    [inputStream close];
    [outputStream close];
}

- (void)write:(NSString *)string {
    if ([outputStream hasSpaceAvailable]) {
        [outputStream write:[[string dataUsingEncoding:NSASCIIStringEncoding] bytes]
            maxLength:[string lengthOfBytesUsingEncoding:NSASCIIStringEncoding]];
    } else {
        [self error:[NSError errorWithDomain:JMRIServiceSimple code:1001 userInfo:nil]];
    }
}

- (void)error:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(simpleService:didFailWithError:)]) {
        [self.delegate simpleService:self didFailWithError:error];
    }
}

#pragma mark - Public methods

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
    uint8_t buf[1024];
    unsigned int len = 0;
    if ([aStream isEqualTo:inputStream]) {
        switch (eventCode) {
            case NSStreamEventNone:
                NSLog(@"[IN] Nothing to see here.");
                break;
            case NSStreamEventOpenCompleted:
                if ([self.delegate respondsToSelector:@selector(simpleServiceDidOpenConnection:)]) {
                    [self.delegate simpleServiceDidOpenConnection:self];
                }
                break;
            case NSStreamEventHasBytesAvailable:
                len = [(NSInputStream *)aStream read:buf maxLength:1024];
                if (len) {
                    NSString *str = [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
                    NSLog(@"[IN] Data received: [%@]", str);
                    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    NSArray *cmds = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
                    for (NSString *cmd in cmds) {
                        if ([self.delegate respondsToSelector:@selector(simpleService:didGetInput:)]) {
                            [self.delegate simpleService:self didGetInput:cmd];
                        }
                        if ([cmd hasPrefix:@"POWER"]) {
                            if ([self.delegate respondsToSelector:@selector(simpleService:didGetPowerState:)]) {
                                NSUInteger state;
                                if ([cmd hasSuffix:@"ON"]) {
                                    state = JMRIItemStateActive;
                                } else if ([cmd hasSuffix:@"OFF"]) {
                                    state = JMRIItemStateInactive;
                                } else if ([cmd hasSuffix:@"UNKNOWN"]) {
                                    state = JMRIItemStateUnknown;
                                }
                                [self.delegate simpleService:self didGetPowerState:state];
                            }
                        }
                    }
                } else {
                    NSLog(@"[IN] No data.");
                }
                break;
            case NSStreamEventErrorOccurred:
                NSLog(@"[IN] An error!");
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"[IN] Over.");
                break;
            default:
                break;
        }
    } else { // event in outputStream
        switch (eventCode) {
            case NSStreamEventNone:
                NSLog(@"[OUT] Nothing to see here.");
                break;
            case NSStreamEventOpenCompleted:
                if ([self.delegate respondsToSelector:@selector(simpleServiceDidOpenConnection:)]) {
                    [self.delegate simpleServiceDidOpenConnection:self];
                }
                break;
            case NSStreamEventHasSpaceAvailable:
                NSLog(@"[OUT] Has space available.");
                break;
            case NSStreamEventErrorOccurred:
                NSLog(@"[OUT] An error!");
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"[OUT] Over.");
            default:
                break;
        }
    }
}

@end
