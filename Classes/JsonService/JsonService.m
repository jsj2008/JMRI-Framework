//
//  JsonService.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JsonService.h"
#import "JMRIConstants.h"
#import "JMRIPanel.h"
#ifdef TARGET_OS_IPHONE
#import "NSStream+JMRIExtensions.h"
#endif

@interface JsonService ()

- (void)open;
- (void)close;
- (void)error:(NSError *)error;

- (void)didGetItem:(NSDictionary *)json;
- (void)didGetLightState:(NSDictionary *)json;
- (void)didGetList:(NSDictionary *)json;
- (void)didGetPowerState:(NSDictionary *)json;
- (void)didGetReporterValue:(NSDictionary *)json;
- (void)didGetSensorState:(NSDictionary *)json;
- (void)didGetSignalHeadState:(NSDictionary *)json;
- (void)didGetTurnoutState:(NSDictionary *)json;

- (void)hello:(NSDictionary *)json;

- (void)sendHeartbeat:(NSTimer *)timer;

@property NSString *buffer;
@property NSTimer *heartbeat;

@end

@implementation JsonService

- (id)initWithNetService:(NSNetService *)service {
    if ((self = [super initWithNetService:service])) {
        serviceType = JMRIServiceJson;
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
        serviceType = JMRIServiceJson;
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
            [self error:[[NSError alloc] initWithDomain:JMRIServiceJson code:1 userInfo:nil]];
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

- (void)write:(NSDictionary *)jsonObject {
    NSError* error = nil;
    NSMutableData *data = [NSMutableData dataWithData:[NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error]];
    if (error != nil) {
        [self error:error];
        return;
    }
    [data appendData:[@"\n\r" dataUsingEncoding:NSUTF8StringEncoding]];
    if ([outputStream hasSpaceAvailable]) {
        [outputStream write:data.bytes maxLength:data.length];
        if ([self.delegate respondsToSelector:@selector(JMRINetService:didSend:)]) {
            [self.delegate JMRINetService:self didSend:data];
        }
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

- (void)list:(NSString *)type {
    [self write:@{@"type": @"list", @"list": type}];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    // {"type":"power","data":{"name":"CT1"}}
    // NSString *string = [NSString stringWithFormat:@"{\"type\":\"%@\",\"data\":{\"name\":\"%@\"}}\n", type, name];
    [self write:@{@"type": type, @"data": @{@"name": name}}];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value {
    [self readItem:name ofType:type];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    //NSString *string = [NSString stringWithFormat:@"{\"type\":\"%@\",\"data\":{\"name\":\"%@\",\"state\":\"%@\"}}\n", type, name, value];
    [self write:@{@"type": type, @"data": @{@"name": name, @"state": value}}];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state {
    [self write:@{@"type": type, @"data": @{@"name": name, @"state":[NSNumber numberWithInteger:state]}}];
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

// Needs to work on data directly to pass to NSJSONSerialization
- (void)didGetInput:(NSInputStream *)stream {
    uint8_t buf[1024];
    NSUInteger len = 0;
    NSString *separator = @"\n\r";
    NSError *error = nil;
    len = [stream read:buf maxLength:1024];
    if (len) {
        NSString *str = [[NSString alloc] initWithBytes:buf length:len encoding:NSASCIIStringEncoding];
        if ([str rangeOfString:separator].location == NSNotFound) {
            self.buffer = [self.buffer stringByAppendingString:str];
        } else {
            str = [[self.buffer stringByAppendingString:str] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.buffer = @"";
            NSArray *lines = [str componentsSeparatedByString:separator];
            for (NSString *line in lines) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[line dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
                if ([self.delegate respondsToSelector:@selector(JMRINetService:didReceive:)]) {
                    [self.delegate JMRINetService:self didReceive:[json description]];
                }
                if ([json[@"type"] isEqualToString:JMRITypeList]) {
                    [self didGetList:json];
                } else {
                    [self didGetItem:json];
                }
            }
        }
    } else {
        NSLog(@"[IN] No data.");
    }
}

- (void)didGetItem:(NSDictionary *)json {
    if ([json[@"type"] isEqualToString:JMRITypeLight]) {
        [self didGetLightState:json];
    } else if ([json[@"type"] isEqualToString:JMRITypePower]) {
        [self didGetPowerState:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeReporter]) {
        [self didGetReporterValue:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeSensor]) {
        [self didGetSensorState:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeTurnout]) {
        [self didGetTurnoutState:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeList]) {
        [self didGetList:json];
    } else if ([json[@"type"] isEqualToString:@"hello"]) {
        [self hello:json];
    }
}

- (void)didGetLightState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetLight:withState:)]) {
        [self.delegate JMRINetService:self didGetLight:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetPowerState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetPowerState:)]) {
        [self.delegate JMRINetService:self didGetPowerState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetReporterValue:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetReporter:withValue:)]) {
        NSString *string = json[@"data"][@"report"];
        NSArray *tokens = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        string = [[[string stringByReplacingOccurrencesOfString:[tokens objectAtIndex:0] withString:@""]
                   stringByReplacingOccurrencesOfString:[tokens objectAtIndex:1] withString:@""]
                  stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [self.delegate JMRINetService:self didGetReporter:json[@"data"][@"name"] withValue:string];
    }
}

- (void)didGetSensorState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSensor:withState:)]) {
        [self.delegate JMRINetService:self didGetSensor:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetSignalHeadState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSignalHead:withState:)]) {
        [self.delegate JMRINetService:self didGetSignalHead:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetTurnoutState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetTurnout:withState:)]) {
        [self.delegate JMRINetService:self didGetTurnout:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetList:(NSDictionary *)json {
    for (NSDictionary *item in json[@"list"]) {
        [self didGetItem:item];
    }
}

- (void)hello:(NSDictionary *)json {
    NSTimeInterval rate = [json[@"data"][@"heartbeat"] integerValue] / 1000.0;
    NSLog(@"Setting heartbeat interval to %f", rate);
    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(sendHeartbeat:) userInfo:nil repeats:YES];
    [self sendHeartbeat:nil];
}

- (void)sendHeartbeat:(NSTimer *)timer {
    [self write:@{@"type": @"ping"}];
}

@end
