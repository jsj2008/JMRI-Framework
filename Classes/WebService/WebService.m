//
//  WebService.m
//  JMRI Framework
//
//  Created by Randall Wood on 28/3/2013.
//
//

#import "WebService.h"

@interface WebService ()

- (void)didGetResponse:(NSHTTPURLResponse *)response withData:(NSData *)data withError:(NSError *)error;

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

@end

@implementation WebService

#pragma mark - Object management

- (id)initWithNetService:(NSNetService *)service {
	if ((self = [super initWithNetService:service])) {
        serviceType = JMRIServiceWeb;
		_openConnections = 0;
		self.JSONPath = @"json/";
        [self readItem:JMRIMetadataJMRICanonicalVersion ofType:JMRITypeMetadata];
	}
	return self;
}

- (id)initWithName:(NSString *)name withAddress:(NSString *)address withPort:(NSInteger)port {
	if ((self = [super initWithName:name withAddress:address withPort:port])) {
        serviceType = JMRIServiceWeb;
		_openConnections = 0;
		self.JSONPath = @"json/";
        [self readItem:JMRIMetadataJMRICanonicalVersion ofType:JMRITypeMetadata];
	}
	return self;
}

- (id)initWithAddress:(NSString *)address withPort:(NSInteger)port {
    return [self initWithName:nil withAddress:address withPort:port];
}

#pragma mark - Properties

- (NSURL *)url {
	if (self.port == -1) {
		return nil;
	}
	if (![self.JSONPath hasPrefix:@"/"]) {
		self.JSONPath = [@"/" stringByAppendingString:self.JSONPath];
	}
    if (![self.JSONPath hasSuffix:@"/"]) {
        self.JSONPath = [self.JSONPath stringByAppendingString:@"/"];
    }
	return [[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li%@", self.hostName, (long)self.port, self.JSONPath, nil]] absoluteURL];
}

- (Boolean)isOpen {
    return (_openConnections);
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

- (void)write:(NSDictionary *)jsonObject {
    NSString *path = [NSString stringWithFormat:@"%@/%@", jsonObject[@"type"], jsonObject[@"data"][@"name"]];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[self.url URLByAppendingPathComponent:path]
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:self.timeoutInterval];
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
    [self write:@{@"type": @"list", @"list": type}];
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

- (void)failWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didFailWithError:)]) {
        [self.delegate JMRINetService:self didFailWithError:error];
    }
}

#pragma mark - Response handlers

- (void)didGetResponse:(NSHTTPURLResponse *)response withData:(NSData *)data withError:(NSError *)error {
    if (response.statusCode == 200 && data) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            switch (error.code) {
                case NSPropertyListReadCorruptError:
                    // The connected JMRI server does not support JSON
                    [self.delegate JMRINetService:self
                                 didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                                      code:JMRIWebServiceJsonUnsupported
                                                                  userInfo:nil]];
                default:
                    NSLog(@"%@", error.description);
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(JMRINetService:didReceive:)]) {
                [self.delegate JMRINetService:self didReceive:[json description]];
            }
            if ([json[@"type"] isEqualToString:JMRITypeList]) {
                [self didGetList:json];
            } else {
                [self didGetItem:json];
            }
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(JMRINetService:didFailWithError:)]) {
            [self.delegate JMRINetService:self didFailWithError:error];
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
    }
}

- (void)didGetLightState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetLight:withState:withProperties:)]) {
        [self.delegate JMRINetService:self didGetLight:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue] withProperties:json];
    }
}

- (void)didGetMemoryValue:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetMemory:withValue:withProperties:)]) {
        [self.delegate JMRINetService:self didGetMemory:json[@"data"][@"name"] withValue:json[@"data"][@"value"] withProperties:json];
    }
}

- (void)didGetMetadata:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetMetadata:withValue:)]) {
        [self.delegate JMRINetService:self didGetMetadata:json[@"data"][@"name"] withValue:json[@"data"][@"value"]];
    }
    if ([json[@"data"][@"name"] isEqualToString:JMRIMetadataJMRICanonicalVersion]) {
        if ([json[@"data"][@"value"] compare:JMRI_WEB_JSON_RECOMMENDED_VERSION options:NSNumericSearch] == NSOrderedAscending) {
            [self.delegate JMRINetService:self
                         didFailWithError:[NSError errorWithDomain:JMRIErrorDomain
                                                              code:JMRIWebServiceJsonReadOnly
                                                          userInfo:@{JMRIMetadataJMRICanonicalVersion: json[@"data"][@"value"]}]];
        }
    }
}

- (void)didGetPowerState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetPowerState:)]) {
        [self.delegate JMRINetService:self didGetPowerState:[json[@"data"][@"state"] integerValue]];
    }
}

- (void)didGetReporterValue:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetReporter:withValue:withProperties:)]) {
        [self.delegate JMRINetService:self didGetReporter:json[@"data"][@"name"] withValue:json[@"data"][@"report"] withProperties:json];
    }
}

- (void)didGetSensorState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSensor:withState:withProperties:)]) {
        [self.delegate JMRINetService:self didGetSensor:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue] withProperties:json];
    }
}

- (void)didGetSignalHeadState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetSignalHead:withState:withProperties:)]) {
        [self.delegate JMRINetService:self didGetSignalHead:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue] withProperties:json];
    }
}

- (void)didGetTurnoutState:(NSDictionary *)json {
    if ([self.delegate respondsToSelector:@selector(JMRINetService:didGetTurnout:withState:withProperties:)]) {
        [self.delegate JMRINetService:self didGetTurnout:json[@"data"][@"name"] withState:[json[@"data"][@"state"] integerValue] withProperties:json];
    }
}

- (void)didGetList:(NSDictionary *)json {
    for (NSDictionary *item in json[@"list"]) {
        [self didGetItem:item];
    }
}

@end
