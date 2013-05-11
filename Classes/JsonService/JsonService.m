//
//  JsonService.m
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JsonService.h"
#import "JMRIConstants.h"
#import "JMRIItem.h"
#import "JMRIPanel.h"
#import "NSMutableArray+QueueExtensions.h"
#ifdef TARGET_OS_IPHONE
#import "NSStream+JMRIExtensions.h"
#endif

@interface JsonService ()

- (void)error:(NSError *)error;
- (void)writeData:(NSData *)data;

- (void)getJsonFromInput;

- (void)didGetItem:(NSDictionary *)json;
- (void)didGetLightState:(NSDictionary *)json;
- (void)didGetList:(NSDictionary *)json;
- (void)didGetMemoryValue:(NSDictionary *)json;
- (void)didGetMetadata:(NSDictionary *)json;
- (void)didGetPowerState:(NSDictionary *)json;
- (void)didGetReporterValue:(NSDictionary *)json;
- (void)didGetSensorState:(NSDictionary *)json;
- (void)didGetSignalHeadState:(NSDictionary *)json;
- (void)didGetTurnoutState:(NSDictionary *)json;

- (void)hello:(NSDictionary *)json;

- (void)sendHeartbeat:(NSTimer *)timer;

@property NSMutableData *buffer;
@property NSTimer *heartbeat;

@end

@implementation JsonService

- (id)initWithNetService:(NSNetService *)service {
    if ((self = [super initWithNetService:service])) {
        [self commonInit];
    }
    return self;
}

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithName:name withAddress:address withPort:port])) {
        serviceVersion = MIN_JSON_VERSION;
        [self commonInit];
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

- (void)commonInit {
    serviceType = JMRIServiceJson;
    [self open];
}

#pragma mark - Public methods

- (void)open {
    if (self.isOpen || self.isOpening) {
        return;
    }
    NSInputStream* is;
    NSOutputStream* os;
    if (self.bonjourService) {
        if ([self.bonjourService getInputStream:&is outputStream:&os]) {
            inputStream = is;
            outputStream = os;
        }
    } else {
#if TARGET_OS_IPHONE
        [NSStream getStreamsToHostNamed:self.addresses[0]
                                   port:self.port
                            inputStream:&is
                           outputStream:&os];
#else
        [NSStream getStreamsToHost:[NSHost hostWithAddress:self.addresses[0]]
                              port:self.port
                       inputStream:&is
                      outputStream:&os];
#endif
        if (is != nil) {
            inputStream = is;
            outputStream = os;
        } else {
            [self error:[[NSError alloc] initWithDomain:JMRIServiceJson code:1 userInfo:nil]];
        }
    }
    self.buffer = [[NSMutableData alloc] init];
    outputQueue = [[NSMutableArray alloc] init];
    self.useQueue = YES;
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream open];
    [outputStream open];
}

- (void)close {
    [self.heartbeat invalidate];
    self.buffer = nil;
    outputQueue = nil;
    [inputStream close];
    [outputStream close];
    inputStream = nil;
    outputStream = nil;
    [self.delegate JMRINetServiceDidStop:self];
}

- (Boolean)isOpening {
    NSStreamStatus i = inputStream.streamStatus;
    NSStreamStatus o = outputStream.streamStatus;
    return i == NSStreamStatusOpening || o == NSStreamStatusOpening;
}

- (Boolean)isOpen {
    NSStreamStatus i = inputStream.streamStatus;
    NSStreamStatus o = outputStream.streamStatus;
    return i >= NSStreamStatusOpen && i < NSStreamStatusAtEnd && o >= NSStreamStatusOpen && o < NSStreamStatusAtEnd;
}

#pragma mark - Private methods

- (void)write:(NSDictionary *)jsonObject {
    NSError* error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
    if (error != nil) {
        [self error:error];
        return;
    }
    [self writeData:data];
}

- (void)writeData:(NSData *)data {
    if ([outputStream hasSpaceAvailable]) {
        [outputStream write:data.bytes maxLength:data.length];
        [self.delegate JMRINetService:self didSend:data];
    } else {
        if (self.useQueue) {
            [outputQueue enqueue:data];
        }
        if (!outputStream) {
            [self open];
        } else if (!self.isOpening) {
            [self error:[NSError errorWithDomain:JMRIErrorDomain code:1001 userInfo:@{@"stream": @"output", @"streamStatus": @(outputStream.streamStatus)}]];
        }
    }
}

- (void)error:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
}

#pragma mark - JMRINetService items

- (void)list:(NSString *)type {
    [self write:@{@"type": @"list", @"list": [self.delegate collectionForType:type]}];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    // {"type":"power","data":{"name":"CT1"}}
    // NSString *string = [NSString stringWithFormat:@"{\"type\":\"%@\",\"data\":{\"name\":\"%@\"}}\n", type, name];
    [self write:@{@"type": type, @"data": @{@"name": name}}];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    //NSString *string = [NSString stringWithFormat:@"{\"type\":\"%@\",\"data\":{\"name\":\"%@\",\"state\":\"%@\"}}\n", type, name, value];
    [self write:@{@"type": type, @"data": @{@"name": name, @"state": value}}];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state {
    [self write:@{@"type": type, @"data": @{@"name": name, @"state":[NSNumber numberWithInteger:state]}}];
}

- (void)writeItem:(JMRIItem *)item {
    [self write:@{@"type": item.type, @"data": item.properties}];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state {
    [self write:@{@"type": type, @"data": @{@"name": name, @"state":[NSNumber numberWithInteger:state], @"method": @"put"}}];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
    [self write:@{@"type": type, @"data": @{@"name": name, @"value":value, @"method": @"put"}}];
}

- (void)createItem:(JMRIItem *)item {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:item.properties];
    [data setValue:@"put" forKey:@"method"];
    [self write:@{@"type": item.type, @"data": data}];
}

- (void)failWithError:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
}

#pragma mark - NSStream delegate

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    if ([aStream isEqual:inputStream]) {
        switch (eventCode) {
            case NSStreamEventNone:
                NSLog(@"[IN] Nothing to see here.");
                break;
            case NSStreamEventOpenCompleted:
                [self.delegate JMRINetServiceDidOpenConnection:self];
                break;
            case NSStreamEventHasBytesAvailable:
                [self didGetInput:inputStream];
                break;
            case NSStreamEventHasSpaceAvailable:
                // should never be called, OutputStream only
                break;
            case NSStreamEventErrorOccurred:
                NSLog(@"[IN] An error!");
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"[IN] Over.");
                break;
            default:
                // should never be called, all events are listed
                break;
        }
    } else { // event in outputStream
        switch (eventCode) {
            case NSStreamEventNone:
                NSLog(@"[OUT] Nothing to see here.");
                break;
            case NSStreamEventOpenCompleted:
                [self.delegate JMRINetServiceDidOpenConnection:self];
            case NSStreamEventHasSpaceAvailable:
                if (![outputQueue isEmpty]) {
                    [self writeData:[outputQueue dequeue]];
                }
                break;
            case NSStreamEventHasBytesAvailable:
                // should never be called, InputStream only
                break;
            case NSStreamEventErrorOccurred:
                NSLog(@"[OUT] An error!");
                break;
            case NSStreamEventEndEncountered:
                NSLog(@"[OUT] Over.");
            default:
                // should never be called, all events are listed
                break;
        }
    }
}

// Needs to work on data directly to pass to NSJSONSerialization
- (void)didGetInput:(NSInputStream *)stream {
    NSInteger max_len = 10240; // little larger than the max size of a packet
    uint8_t buf[max_len];
    NSUInteger len = 0;
    len = [stream read:buf maxLength:max_len];
    if (len) {
        [self.buffer appendData:[NSData dataWithBytes:buf length:len]];
        [self getJsonFromInput];
    } else {
        NSLog(@"[IN] No data.");
    }
}

- (void)getJsonFromInput {
    @synchronized(self) {
        NSError *error = nil;
        NSData *objStart = [@"{" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *objEnd = [@"}" dataUsingEncoding:NSUTF8StringEncoding];
        NSUInteger objects = 1;
        NSRange jsonObj = [self.buffer rangeOfData:objStart options:0 range:NSMakeRange(0, self.buffer.length)];
        if (jsonObj.length) {
            const char* startBytes = [objStart bytes];
            const char* endBytes = [objEnd bytes];
            const char* bufferBytes = [self.buffer bytes];
            jsonObj.length = 0;
            for (NSUInteger i = jsonObj.location + objStart.length; i < self.buffer.length; i++) {
                if (objects) {
                    if (bufferBytes[i] == startBytes[0]) {
                        objects++;
                    } else if (bufferBytes[i] == endBytes[0]) {
                        objects--;
                    }
                } else {
                    jsonObj.length = i - jsonObj.location + objEnd.length;
                    break;
                }
            }
        }
        if (jsonObj.length && jsonObj.location) { // remove anything before the first object
            [self.buffer replaceBytesInRange:NSMakeRange(0, jsonObj.location - 1) withBytes:NULL length:0];
        }
        if (jsonObj.length) {
            jsonObj.location = 0;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[self.buffer subdataWithRange:jsonObj] options:0 error:&error];
            [self.buffer replaceBytesInRange:jsonObj withBytes:NULL length:0];
            if (!error) {
                [self.delegate JMRINetService:self didReceive:[json description]];
                if ([json[@"type"] isEqualToString:JMRITypeList]) {
                    [self didGetList:json];
                } else {
                    [self didGetItem:json];
                }
            }
            if (self.buffer.length) {
                [self getJsonFromInput];
            }
        }
    }
}

- (void)didGetItem:(NSDictionary *)json {
    if ([json[@"type"] isEqualToString:JMRITypeLight]) {
        [self didGetLightState:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeMemory]) {
        [self didGetMemoryValue:json];
    } else if ([json[@"type"] isEqualToString:JMRITypeMetadata]) {
        [self didGetMetadata:json];
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
    NSUInteger state = [json[@"data"][@"state"] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetLight:json[@"data"][@"name"] withState:state withProperties:json[@"data"]];
}

- (void)didGetMemoryValue:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetMemory:json[@"data"][@"name"] withValue:json[@"data"][@"value"] withProperties:json[@"data"]];
}

- (void)didGetMetadata:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetMetadata:json[@"data"][@"name"] withValue:json[@"data"][@"value"] withProperties:json[@"data"]];
}

- (void)didGetPowerState:(NSDictionary *)json {
    NSUInteger state = [json[@"data"][@"state"] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetPowerState:state];
}

- (void)didGetReporterValue:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetReporter:json[@"data"][@"name"] withValue:json[@"data"][@"report"] withProperties:json[@"data"]];
}

- (void)didGetSensorState:(NSDictionary *)json {
    NSUInteger state = [json[@"data"][@"state"] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetSensor:json[@"data"][@"name"] withState:state withProperties:json[@"data"]];
}

- (void)didGetSignalHeadState:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetSignalHead:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue] withProperties:json[@"data"]];
}

- (void)didGetTurnoutState:(NSDictionary *)json {
    NSUInteger state = [json[@"data"][@"state"] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetTurnout:json[@"data"][@"name"] withState:state withProperties:json[@"data"]];
}

- (void)didGetList:(NSDictionary *)json {
    for (NSDictionary *item in json[@"list"]) {
        [self didGetItem:item];
    }
}

- (void)hello:(NSDictionary *)json {
    NSTimeInterval rate = [json[@"data"][@"heartbeat"] integerValue] / 1000.0;
    serviceVersion = json[@"data"][@"JMRI"];
    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(sendHeartbeat:) userInfo:nil repeats:YES];
    [self sendHeartbeat:nil];
    [self.delegate JMRINetServiceDidStart:self];
}

- (void)sendHeartbeat:(NSTimer *)timer {
    [self write:@{@"type": @"ping"}];
}

@end
