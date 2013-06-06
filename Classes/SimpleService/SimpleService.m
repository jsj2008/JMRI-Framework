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

- (void)error:(NSError *)error;

- (void)didGetLightState:(NSString *)string;
- (void)didGetPowerState:(NSString *)string;
- (void)didGetReporterValue:(NSString *)string;
- (void)didGetSensorState:(NSString *)string;
- (void)didGetSignalHeadState:(NSString *)string;
- (void)didGetTurnoutState:(NSString *)string;

- (void)hello:(NSString *)string;

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

#pragma mark - Public methods

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

- (Boolean)isOpen {
    NSStreamStatus i = inputStream.streamStatus;
    NSStreamStatus o = outputStream.streamStatus;
    return i >= NSStreamStatusOpen && i < NSStreamStatusAtEnd && o >= NSStreamStatusOpen && o < NSStreamStatusAtEnd;
}

#pragma mark - Private methods

- (void)write:(NSString *)string {
    if ([outputStream hasSpaceAvailable]) {
        [outputStream write:[[string dataUsingEncoding:NSASCIIStringEncoding] bytes]
            maxLength:[string lengthOfBytesUsingEncoding:NSASCIIStringEncoding]];
    } else {
        [self error:[NSError errorWithDomain:JMRIErrorDomain code:1001 userInfo:nil]];
    }
}

- (void)error:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
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
    [self.delegate JMRINetService:self didFailWithError:error];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if ([aStream isEqual:inputStream]) {
        switch (eventCode) {
            case NSStreamEventNone:
                [self.delegate logEvent:@"[IN] Nothing to see here."];
                break;
            case NSStreamEventOpenCompleted:
                [self.delegate JMRINetServiceDidOpenConnection:self];
                break;
            case NSStreamEventHasBytesAvailable:
                [self didGetInput:inputStream];
                break;
            case NSStreamEventErrorOccurred:
                [self.delegate logEvent:@"[IN] An error!"];
                break;
            case NSStreamEventEndEncountered:
                [self.delegate logEvent:@"[IN] Over."];
                break;
            default:
                break;
        }
    } else { // event in outputStream
        switch (eventCode) {
            case NSStreamEventNone:
                [self.delegate logEvent:@"[OUT] Nothing to see here."];
                break;
            case NSStreamEventOpenCompleted:
                [self.delegate JMRINetServiceDidOpenConnection:self];
                break;
            case NSStreamEventHasSpaceAvailable:
                break;
            case NSStreamEventErrorOccurred:
                [self.delegate logEvent:@"[OUT] An error!"];
                break;
            case NSStreamEventEndEncountered:
                [self.delegate logEvent:@"[OUT] Over."];
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
                [self.delegate JMRINetService:self didReceive:cmd];
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
                } else if ([cmd hasPrefix:@"JMRI"]) {
                    [self hello:cmd];
                }
            }
        }
    } else {
        [self.delegate logEvent:@"[IN] No data."];
    }
}

- (void)didGetLightState:(NSString *)string {
    NSUInteger state;
    NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[tokens objectAtIndex:2] isEqualToString:@"ON"]) {
        state = JMRIItemStateActive;
    } else if ([[tokens objectAtIndex:2] isEqualToString:@"OFF"]) {
        state = JMRIItemStateInactive;
    } else {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetLight:[tokens objectAtIndex:1] withState:state withProperties:nil];
}

- (void)didGetPowerState:(NSString *)string {
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

- (void)didGetReporterValue:(NSString *)string {
    NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    string = [[[string stringByReplacingOccurrencesOfString:[tokens objectAtIndex:0] withString:@""]
               stringByReplacingOccurrencesOfString:[tokens objectAtIndex:1] withString:@""]
              stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.delegate JMRINetService:self didGetReporter:[tokens objectAtIndex:1] withValue:string withProperties:nil];
}

- (void)didGetSensorState:(NSString *)string {
    NSUInteger state;
    NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[tokens objectAtIndex:2] isEqualToString:@"ACTIVE"]) {
        state = JMRIItemStateActive;
    } else if ([[tokens objectAtIndex:2] isEqualToString:@"INACTIVE"]) {
        state = JMRIItemStateInactive;
    } else {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetSensor:[tokens objectAtIndex:1] withState:state withProperties:nil];
}

- (void)didGetSignalHeadState:(NSString *)string {
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
    [self.delegate JMRINetService:self didGetSignalHead:[tokens objectAtIndex:1] withState:state withProperties:nil];
}

- (void)didGetTurnoutState:(NSString *)string {
    NSUInteger state;
    NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([[tokens objectAtIndex:2] isEqualToString:@"THROWN"]) {
        state = JMRIItemStateActive;
    } else if ([[tokens objectAtIndex:2] isEqualToString:@"CLOSED"]) {
        state = JMRIItemStateInactive;
    } else {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetTurnout:[tokens objectAtIndex:1] withState:state withProperties:nil];
}

- (void)hello:(NSString *)string {
    NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    serviceVersion = tokens[1];
}

@end
