//
//  SimpleService.m
//  JMRI Framework
//
//  Created by Randall Wood on 28/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "SimpleService.h"
#import "JMRIConstants.h"
#import "JMRIPanel.h"
#ifdef TARGET_OS_IPHONE
#import "NSStream+JMRIExtensions.h"
#endif

@interface SimpleService ()

- (void)open;
- (void)close;
- (void)error:(NSError *)error;

- (void)didGetLightState:(NSString *)string;
- (void)didGetPowerState:(NSString *)string;
- (void)didGetReporterValue:(NSString *)string;
- (void)didGetSensorState:(NSString *)string;
- (void)didGetSignalHeadState:(NSString *)string;
- (void)didGetTurnoutState:(NSString *)string;

@property NSString *buffer;

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

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithName:name withAddress:address withPort:port])) {
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

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

#pragma mark - Private methods

- (void)open {
    self.buffer = @"";
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)close {
    self.buffer = nil;
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
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didFailWithError:)]) {
        [self.delegate JMRINetService:self didFailWithError:error];
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

- (void)failWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didFailWithError:)]) {
        [self.delegate JMRINetService:self didFailWithError:error];
    }
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if ([aStream isEqual:inputStream]) {
        switch (eventCode) {
            case NSStreamEventNone:
                NSLog(@"[IN] Nothing to see here.");
                break;
            case NSStreamEventOpenCompleted:
                if ([self.delegate respondsToSelector:@selector(JMRINetServiceDidOpenConnection:)]) {
                    [self.delegate JMRINetServiceDidOpenConnection:self];
                }
                break;
            case NSStreamEventHasBytesAvailable:
                [self didGetInput:inputStream];
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
                if ([self.delegate respondsToSelector:@selector(JMRINetServiceDidOpenConnection:)]) {
                    [self.delegate JMRINetServiceDidOpenConnection:self];
                }
                break;
            case NSStreamEventHasSpaceAvailable:
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

- (void)didGetInput:(NSInputStream *)stream {
    uint8_t buf[1024];
    NSUInteger len = 0;
    len = [stream read:buf maxLength:1024];
    if (len) {
        NSString *str = [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
        if ([str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]].location == NSNotFound) {
            self.buffer = [self.buffer stringByAppendingString:str];
        } else {
            str = [[self.buffer stringByAppendingString:str] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.buffer = @"";
            NSArray *cmds = [str componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            for (NSString *cmd in cmds) {
                if ([self.delegate respondsToSelector:@selector(JMRINetService:didReceive:)]) {
                    [self.delegate JMRINetService:self didReceive:cmd];
                }
                if ([cmd hasPrefix:@"LIGHT"]) {
                    [self didGetLightState:cmd];
                } else if ([cmd hasPrefix:@"POWER"]) {
                    [self didGetPowerState:cmd];
                } else if ([cmd hasPrefix:@"REPORTER"]) {
                    [self didGetReporterValue:cmd];
                } else if ([cmd hasPrefix:@"SENSOR"]) {
                    [self didGetSensorState:cmd];
                } else if ([cmd hasPrefix:@"TURNOUT"]) {
                    [self didGetTurnoutState:cmd];
                }
            }
        }
    } else {
        NSLog(@"[IN] No data.");
    }
}

- (void)didGetLightState:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetLight:withState:)]) {
        NSUInteger state;
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([[tokens objectAtIndex:2] isEqualToString:@"ON"]) {
            state = JMRIItemStateActive;
        } else if ([[tokens objectAtIndex:2] isEqualToString:@"OFF"]) {
            state = JMRIItemStateInactive;
        } else {
            state = JMRIItemStateUnknown;
        }
        [self.delegate JMRINetService:self didGetLight:[tokens objectAtIndex:1] withState:state];
    }
}

- (void)didGetPowerState:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetPowerState:)]) {
        NSUInteger state;
        if ([string hasSuffix:@"ON"]) {
            state = JMRIItemStateActive;
        } else if ([string hasSuffix:@"OFF"]) {
            state = JMRIItemStateInactive;
        } else {
            state = JMRIItemStateUnknown;
        }
        [self.delegate JMRINetService:self didGetPowerState:state];
    }
}

- (void)didGetReporterValue:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetReporter:withValue:)]) {
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        string = [[[string stringByReplacingOccurrencesOfString:[tokens objectAtIndex:0] withString:@""]
                   stringByReplacingOccurrencesOfString:[tokens objectAtIndex:1] withString:@""]
                  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self.delegate JMRINetService:self didGetReporter:[tokens objectAtIndex:1] withValue:string];
    }
}

- (void)didGetSensorState:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSensor:withState:)]) {
        NSUInteger state;
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([[tokens objectAtIndex:2] isEqualToString:@"ACTIVE"]) {
            state = JMRIItemStateActive;
        } else if ([[tokens objectAtIndex:2] isEqualToString:@"INACTIVE"]) {
            state = JMRIItemStateInactive;
        } else {
            state = JMRIItemStateUnknown;
        }
        [self.delegate JMRINetService:self didGetSensor:[tokens objectAtIndex:1] withState:state];
    }
}

- (void)didGetSignalHeadState:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSignalHead:withState:)]) {
        NSUInteger state = JMRISignalAppearanceDark;
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        // since dark is the default/fallback state, we aren't checking for it.
        if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalFlashGreen]) {
            state = JMRISignalAppearanceFlashGreen;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalFlashLunar]) {
            state = JMRISignalAppearanceFlashLunar;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalFlashRed]) {
            state = JMRISignalAppearanceFlashRed;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalFlashYellow]) {
            state = JMRISignalAppearanceFlashYellow;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalGreen]) {
            state = JMRISignalAppearanceGreen;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalLunar]) {
            state = JMRISignalAppearanceLunar;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalRed]) {
            state = JMRISignalAppearanceRed;
        } else if ([[tokens objectAtIndex:2] isEqualToString:JMRIPanelSignalYellow]) {
            state = JMRISignalAppearanceYellow;
        }
        [self.delegate JMRINetService:self didGetSignalHead:[tokens objectAtIndex:1] withState:state];
    }
}

- (void)didGetTurnoutState:(NSString *)string {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetTurnout:withState:)]) {
        NSUInteger state;
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([[tokens objectAtIndex:2] isEqualToString:@"THROWN"]) {
            state = JMRIItemStateActive;
        } else if ([[tokens objectAtIndex:2] isEqualToString:@"CLOSED"]) {
            state = JMRIItemStateInactive;
        } else {
            state = JMRIItemStateUnknown;
        }
        [self.delegate JMRINetService:self didGetTurnout:[tokens objectAtIndex:1] withState:state];
    }
}

@end
