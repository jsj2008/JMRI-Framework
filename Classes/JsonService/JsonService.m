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
#import "NSMutableArray+QueueExtensions.h"
#import "SocketRocket/SRWebSocket.h"
#ifdef TARGET_OS_IPHONE
#import "NSStream+JMRIExtensions.h"
#endif

@interface JsonService () <SRWebSocketDelegate>

- (void)error:(NSError *)error;
- (void)writeData:(NSData *)data;

- (void)getJsonFromInput;
- (NSRange)rangeOfJson:(NSUInteger)location start:(NSData *)start end:(NSData *)end;

- (void)hello:(NSDictionary *)json;
- (void)didGetItem:(NSDictionary *)json;
- (void)didGetLightState:(NSDictionary *)json;
- (void)didGetList:(NSObject *)json;
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
@property (strong) SRWebSocket *webSocket;
@property Boolean webSocketIsOpening;
@property Boolean webSocketIsOpen;

@end

@implementation JsonService

@synthesize webSocketURL = _webSocketURL;

- (id)initWithNetService:(NSNetService *)service {
    if ((self = [super initWithNetService:service])) {
        _webSocketURL = nil;
        _webSocket = nil;
        [self commonInit];
    }
    return self;
}

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
    if ((self = [super initWithName:name withAddress:address withPort:port])) {
        _webSocketURL = nil;
        _webSocket = nil;
        serviceVersion = MIN_JSON_VERSION;
        [self commonInit];
    }
    return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

- (id)initWithName:(NSString *)name withURL:(NSURL *)URL {
    if ((self = [super initWithName:name withAddress:URL.host withPort:[URL.port integerValue]])) {
        _webSocketURL = URL;
        _webSocket = [[SRWebSocket alloc] initWithURL:URL];
        _webSocket.delegate = self;
        _webSocketIsOpening = NO;
        _webSocketIsOpen = NO;
        serviceVersion = MIN_JSON_VERSION;
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    serviceType = JMRIServiceJson;
    outputQueue = [[NSMutableArray alloc] initWithCapacity:0];
    [self open];
}

#pragma mark - Public methods

- (void)open {
    if (self.isOpen || self.isOpening) {
        return;
    }
    if (self.webSocketURL) {
        if (!self.webSocket) {
            self.webSocket = [[SRWebSocket alloc] initWithURL:self.webSocketURL];
        }
        [self.webSocket open];
        self.webSocketIsOpening = YES;
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
    [self.webSocket close];
    inputStream = nil;
    outputStream = nil;
    self.webSocket = nil;
    [self.delegate JMRINetServiceDidStop:self];
}

- (Boolean)isOpening {
    if (self.webSocket) {
        return self.webSocketIsOpening;
    }
    NSStreamStatus i = inputStream.streamStatus;
    NSStreamStatus o = outputStream.streamStatus;
    return i == NSStreamStatusOpening || o == NSStreamStatusOpening;
}

- (Boolean)isOpen {
    if (self.webSocket) {
        return self.webSocketIsOpen;
    }
    NSStreamStatus i = inputStream.streamStatus;
    NSStreamStatus o = outputStream.streamStatus;
    return i >= NSStreamStatusOpen && i < NSStreamStatusAtEnd && o >= NSStreamStatusOpen && o < NSStreamStatusAtEnd;
}

- (NSURL *)webSocketURL {
    if (self.webSocket) {
        return self.webSocket.url;
    }
    return _webSocketURL;
}

- (void)setWebSocketURL:(NSURL *)webSocketURL {
    _webSocketURL = webSocketURL;
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
    if (self.webSocketURL) {
        if (self.webSocketIsOpen) {
            if (![outputQueue isEmpty]) {
                [self writeData:[outputQueue dequeue]];
            }
            NSString *string = [NSString stringWithUTF8String:[data bytes]];
            if (string.length) {
                [self.webSocket send:string];
            }
            string = nil;
        } else {
            if (self.useQueue) {
                [outputQueue enqueue:data];
            }
            [self open];
        }
    } else {
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
    data = nil;
}

- (void)error:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
}

#pragma mark - JMRINetService items

- (void)list:(NSString *)type {
    [self write:@{JMRIList: [self.delegate collectionForType:type]}];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    [self write:@{JMRIType: type, JMRIJsonData: @{JMRIItemName: name}}];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    [self write:@{JMRIType: type, JMRIJsonData: @{JMRIItemName: name, JMRIItemState: value}}];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state {
    [self write:@{JMRIType: type, JMRIJsonData: @{JMRIItemName: name, JMRIItemState:[NSNumber numberWithInteger:state]}}];
}

- (void)writeItem:(JMRIItem *)item {
    [self write:@{JMRIType: item.type, JMRIJsonData: item.properties}];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state {
    [self write:@{JMRIType: type, JMRIJsonData: @{JMRIItemName: name, JMRIItemState:[NSNumber numberWithInteger:state], @"method": @"put"}}];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
    [self write:@{JMRIType: type, JMRIJsonData: @{JMRIItemName: name, JMRIItemValue:value, @"method": @"put"}}];
}

- (void)createItem:(JMRIItem *)item {
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:item.properties];
    [data setValue:@"put" forKey:@"method"];
    [self write:@{JMRIType: item.type, JMRIJsonData: data}];
}

- (void)failWithError:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
}


#pragma mark - SRWebSocket delegate

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSError *error;
    NSObject *json = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    if (error) {
        switch (error.code) {
            case NSPropertyListReadCorruptError:
                // The connected JMRI server does not support JSON
                [self.delegate JMRINetService:self
                             didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                  code:JMRIWebServiceJsonUnsupported
                                                              userInfo:nil]];
            default:
                [self.delegate logEvent:@"WebSocket/JSON error %@", error.localizedDescription];
        }
    } else {
        [self.delegate JMRINetService:self didReceive:[json description]];
        if ([json isKindOfClass:[NSArray class]] || [((NSDictionary *)json)[JMRIType] isEqualToString:JMRITypeList]) {
            [self didGetList:json];
        } else {
            [self didGetItem:(NSDictionary *)json];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    self.webSocketIsOpen = YES;
    if (![outputQueue isEmpty]) {
        [self writeData:[outputQueue dequeue]];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    [self.delegate logEvent:@"Socket failed because %@", error.localizedDescription];
    [self.delegate JMRINetService:self didFailWithError:error];
    [self close];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    self.webSocketIsOpen = NO;
    [self close];
    [self.delegate logEvent:@"Socket closed (%@) because %@ (%ld).", (wasClean) ? @"clean" : @"dirty", reason, (long)code];
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
            case NSStreamEventHasSpaceAvailable:
                // should never be called, OutputStream only
                break;
            case NSStreamEventErrorOccurred:
                [self.delegate logEvent:@"JSONService inputStream error %@", [inputStream streamError].debugDescription];
                [self.delegate JMRINetService:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                                        code:JMRIInputStreamError
                                                                                    userInfo:@{@"streamError": [inputStream streamError]}]];
                break;
            case NSStreamEventEndEncountered:
                [self.delegate logEvent:@"JSONService inputStream closed by server."];
                [self close];
                break;
            default:
                // should never be called, all events are listed
                break;
        }
    } else { // event in outputStream
        switch (eventCode) {
            case NSStreamEventNone:
                [self.delegate logEvent:@"[OUT] Nothing to see here."];
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
                [self.delegate logEvent:@"JSONService outputStream error %@", [outputStream streamError].debugDescription];
                [self.delegate JMRINetService:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                                        code:JMRIInputStreamError
                                                                                    userInfo:@{@"streamError": [outputStream streamError]}]];
                break;
            case NSStreamEventEndEncountered:
                [self.delegate logEvent:@"JSONService outputStream closed by server."];
                [self close];
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
        [self.delegate logEvent:@"[IN] No data."];
    }
}

- (void)getJsonFromInput {
    @synchronized(self) {
        NSError *error = nil;
        NSData *objStart = [@"{" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *objEnd = [@"}" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *arrStart = [@"[" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *arrEnd = [@"]" dataUsingEncoding:NSUTF8StringEncoding];
        NSRange jsonObj = [self.buffer rangeOfData:objStart options:0 range:NSMakeRange(0, self.buffer.length)];
        NSRange jsonArr = [self.buffer rangeOfData:arrStart options:0 range:NSMakeRange(0, self.buffer.length)];
        NSRange jsonRange = jsonArr;
        Boolean isObject = NO;
        const char* startBytes = [arrStart bytes];
        const char* endBytes = [arrEnd bytes];
        if ((jsonObj.length && !jsonArr.length) || (jsonObj.location < jsonArr.location)) {
            isObject = YES;
            jsonRange = jsonObj;
            startBytes = [objStart bytes];
            endBytes = [objEnd bytes];
        }
        NSUInteger objects = 1;
        if (jsonRange.length) {
            jsonRange.length = 0; // reset for later checks don't fail on incomplete objects
            const char* bufferBytes = [self.buffer bytes];
            for (NSUInteger i = jsonRange.location + objStart.length; i < self.buffer.length; i++) {
                if (objects) {
                    if (bufferBytes[i] == startBytes[0]) {
                        objects++;
                    } else if (bufferBytes[i] == endBytes[0]) {
                        objects--;
                    }
                }
                if (!objects) {
                    jsonRange.length = i - jsonRange.location + objEnd.length;
                    break;
                }
            }
        }
        if (jsonRange.length && jsonRange.location) { // remove anything before the first object
            [self.buffer replaceBytesInRange:NSMakeRange(0, jsonRange.location) withBytes:NULL length:0];
        }
        if (jsonRange.length) {
            jsonRange.location = 0;
            NSObject *json = [NSJSONSerialization JSONObjectWithData:[self.buffer subdataWithRange:jsonRange] options:0 error:&error];
            [self.buffer replaceBytesInRange:jsonRange withBytes:NULL length:0];
            if (!error) {
                [self.delegate JMRINetService:self didReceive:[json description]];
                if (isObject) {
                    if ([((NSDictionary *)json)[JMRIType] isEqualToString:JMRITypeList]) {
                        [self didGetList:json];
                    } else {
                        [self didGetItem:(NSDictionary *)json];
                    }
                } else {
                    [self didGetList:json];
                }
            } else {
                [self.delegate logEvent:@"JSONService error processing JSON: %@", error.debugDescription];
            }
            if (self.buffer.length) {
                [self getJsonFromInput];
            }
        }
    }
}

- (NSRange)rangeOfJson:(NSUInteger)location start:(NSData *)start end:(NSData *)end {
    @synchronized (self) {
        NSRange range = NSMakeRange(location, 0);
        return range;
    }
}

- (void)didGetItem:(NSDictionary *)json {
    if ([json[JMRIType] isEqualToString:JMRITypeLight]) {
        [self didGetLightState:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeMemory]) {
        [self didGetMemoryValue:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeMetadata]) {
        [self didGetMetadata:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypePower]) {
        [self didGetPowerState:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeReporter]) {
        [self didGetReporterValue:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeSensor]) {
        [self didGetSensorState:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeTurnout]) {
        [self didGetTurnoutState:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeList]) {
        [self didGetList:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeHello]) {
        [self hello:json];
    } else if ([json[JMRIType] isEqualToString:JMRITypeGoodbye]) {
        [self close];
    }
}

- (void)didGetLightState:(NSDictionary *)json {
    NSUInteger state = [json[JMRIJsonData][JMRIItemState] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetLight:json[JMRIJsonData][JMRIItemName] withState:state withProperties:json[JMRIJsonData]];
}

- (void)didGetMemoryValue:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetMemory:json[JMRIJsonData][JMRIItemName] withValue:json[JMRIJsonData][JMRIItemValue] withProperties:json[JMRIJsonData]];
}

- (void)didGetMetadata:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetMetadata:json[JMRIJsonData][JMRIItemName] withValue:json[JMRIJsonData][JMRIItemValue] withProperties:json[JMRIJsonData]];
}

- (void)didGetPowerState:(NSDictionary *)json {
    NSUInteger state = [json[JMRIJsonData][JMRIItemState] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetPowerState:state];
}

- (void)didGetReporterValue:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetReporter:json[JMRIJsonData][JMRIItemName] withValue:json[JMRIJsonData][@"report"] withProperties:json[JMRIJsonData]];
}

- (void)didGetSensorState:(NSDictionary *)json {
    NSUInteger state = [json[JMRIJsonData][JMRIItemState] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetSensor:json[JMRIJsonData][JMRIItemName] withState:state withProperties:json[JMRIJsonData]];
}

- (void)didGetSignalHeadState:(NSDictionary *)json {
    [self.delegate JMRINetService:self didGetSignalHead:json[JMRIJsonData][JMRIItemName] withState:[json[JMRIJsonData][JMRIItemState] integerValue] withProperties:json[JMRIJsonData]];
}

- (void)didGetTurnoutState:(NSDictionary *)json {
    NSUInteger state = [json[JMRIJsonData][JMRIItemState] integerValue];
    if (state == JMRIBeanStateUnknown) {
        state = JMRIItemStateUnknown;
    }
    [self.delegate JMRINetService:self didGetTurnout:json[JMRIJsonData][JMRIItemName] withState:state withProperties:json[JMRIJsonData]];
}

- (void)didGetList:(NSObject *)json {
    if ([json isKindOfClass:[NSDictionary class]]) {
        for (NSDictionary *item in ((NSDictionary *)json)[JMRITypeList]) {
            [self didGetItem:item];
        }
    } else {
        for (NSDictionary *item in (NSArray *)json) {
            [self didGetItem:item];
        }
    }
}

- (void)hello:(NSDictionary *)json {
    NSTimeInterval rate = [json[JMRIJsonData][@"heartbeat"] integerValue] / 1000.0;
    serviceVersion = json[JMRIJsonData][@"JMRI"];
    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:rate target:self selector:@selector(sendHeartbeat:) userInfo:nil repeats:YES];
    [self sendHeartbeat:nil];
    [self.delegate JMRINetServiceDidStart:self];
}

- (void)sendHeartbeat:(NSTimer *)timer {
    [self write:@{JMRIType: @"ping"}];
}

@end
