//
//  WebService.m
//  JMRI Framework
//
//  Created by Randall Wood on 28/3/2013.
//
//

#import "WebService.h"
#import "JMRIItem.h"

@interface WebService ()

- (void)didGetResponse:(NSHTTPURLResponse *)response withData:(NSData *)data withError:(NSError *)error;

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

@end

NSString *const rootPath = @"/";

@implementation WebService

#pragma mark - Object management

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super initWithNetService:service])) {
        [self commonInit];
	}
	return self;
}

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super initWithName:name withAddress:address withPort:port])) {
        [self commonInit];
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

- (void)commonInit {
    serviceType = JMRIServiceWeb;
    _openConnections = 0;
    self.jsonPath = @"json/";
    [self read:JMRITypeHello];
    [self readItem:JMRIMetadataJMRICanonicalVersion ofType:JMRITypeMetadata];
}

#pragma mark - Properties

- (NSURL *)urlWithFormat:(NSString *)format {
	if (self.port == -1) {
		return nil;
	}
	if (![self.jsonPath hasPrefix:rootPath]) {
		self.jsonPath = [rootPath stringByAppendingString:self.jsonPath];
	}
    if (![self.jsonPath hasSuffix:rootPath]) {
        self.jsonPath = [self.jsonPath stringByAppendingString:rootPath];
    }
	return [[NSURL URLWithString:[NSString stringWithFormat:format, self.hostName, (long)self.port, self.jsonPath, nil]] absoluteURL];
}

- (NSURL *)url {
    return [self urlWithFormat:@"http://%@:%li%@"];
}

- (Boolean)isOpen {
    return (_openConnections);
}

- (NSURL *)socketURL {
    return [self urlWithFormat:@"ws://%@:%li%@"];
}

#pragma mark - Private methods

- (void)read:(NSString *)path {
    NSURLRequest* request = [NSURLRequest requestWithURL:[self.url URLByAppendingPathComponent:path]
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:self.timeoutInterval];
    _openConnections++;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               _openConnections--;
                               [self didGetResponse:(NSHTTPURLResponse *)response withData:data withError:error];
                           }];
}

- (void)write:(NSDictionary *)jsonObject type:(NSString *)type method:(NSString *)method {
    // need to pluralize type
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:&error];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self.delegate collectionForType:type], jsonObject[JMRIJsonData][JMRIItemName]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[self.url URLByAppendingPathComponent:path]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeoutInterval];
    request.HTTPMethod = method;
    request.HTTPBody = data;
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[[NSNumber numberWithUnsignedInteger:data.length] stringValue] forHTTPHeaderField:@"Content-Length"];
    _openConnections++;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               _openConnections--;
                               [self didGetResponse:(NSHTTPURLResponse *)response withData:data withError:error];
                           }];
}

#pragma mark - JMRINetService items

- (void)list:(NSString *)type {
    [self read:[self.delegate collectionForType:type]];
}

- (void)readItem:(NSString *)name ofType:(NSString *)type {
    [self read:[NSString stringWithFormat:@"%@/%@", type, name]];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value {
    [self write:@{JMRIItemName: name, JMRIItemState: value} type:type method:HTTPMethodPost];
}

- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state {
    [self write:@{JMRIItemName: name, JMRIItemState:[NSNumber numberWithInteger:state]} type:type method:HTTPMethodPost];
}

- (void)writeItem:(JMRIItem *)item ofType:(NSString *)type {
    [self write:item.properties type:type method:HTTPMethodPost];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state {
    [self write:@{JMRIItemName: name, JMRIItemState:[NSNumber numberWithInteger:state]} type:type method:HTTPMethodPut];
}

- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value {
    [self write:@{JMRIItemName: name, JMRIItemValue:value} type:type method:HTTPMethodPut];
}

- (void)createItem:(JMRIItem *)item ofType:(NSString *)type {
    [self write:item.properties type:type method:HTTPMethodPut];
}

- (void)failWithError:(NSError *)error {
    [self.delegate JMRINetService:self didFailWithError:error];
}

#pragma mark - Response handlers

- (void)didGetResponse:(NSHTTPURLResponse *)response withData:(NSData *)data withError:(NSError *)error {
    NSObject *json = nil;
    if (response.statusCode == 200 && data) {
        json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            switch (error.code) {
                case NSPropertyListReadCorruptError:
                    // The connected JMRI server does not support JSON
                    [self.delegate JMRINetService:self
                                 didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                      code:JMRIWebServiceJsonUnsupported
                                                                  userInfo:nil]];
                default:
                    [self.delegate logEvent:@"WebService/JSON failure %@", error.localizedDescription];
            }
        } else {
            [self.delegate JMRINetService:self didReceive:[json description]];
            if ([json isKindOfClass:[NSArray class]] || [((NSDictionary *)json)[JMRIType] isEqualToString:JMRITypeList]) {
                [self didGetList:json];
            } else {
                [self didGetItem:(NSDictionary *)json];
            }
        }
    } else if (response.statusCode == 404 && [response.URL.path hasSuffix:JMRITypeHello]) {
        [self.delegate JMRINetService:self didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                                code:JMRIWebServiceJsonUnsupported
                                                                            userInfo:nil]];
    } else {
        if (data) {
            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        if (json) {
            error = [NSError errorWithDomain:JMRIErrorDomain code:response.statusCode userInfo:(NSDictionary *)json];
        }
        if (!error) {
            error = [NSError errorWithDomain:JMRIErrorDomain code:response.statusCode userInfo:@{@"URL": response.URL.path, @"response": response}];
        }
        [self.delegate logEvent:@"Web Service failure %lu for %@", (long)response.statusCode, response.URL.path];
        [self.delegate JMRINetService:self didFailWithError:error];
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

- (void)didGetList:(NSDictionary *)json {
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
    serviceVersion = json[JMRIJsonData][JMRITXTRecordKeyJMRI];
    if (json[JMRIJsonData][JMRITXTRecordKeyJSON]) {
        [self.delegate useJsonServiceWithURL:[self socketURL]];
    }
}

@end
