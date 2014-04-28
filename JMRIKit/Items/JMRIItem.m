//
//  JMRIItem.m
//  JMRI-Framework
//
//  Created by Randall Wood on 10/7/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import "JMRIItem+Internal.h"
#import "JMRIService+Internal.h"
#import "JMRIConstants.h"
#import "JMRINetService.h"
#import "JsonService.h"
#import "WiThrottleService.h"

@implementation JMRIItem

#pragma mark - Initializers

- (id)initWithName:(NSString *)name withService:(JMRIService *)service {
    if ((self = [self initWithName:name withService:service withProperties:nil])) {
        [self query];
    }
    return self;
}

- (id)initWithName:(NSString *)name withService:(JMRIService *)service withProperties:(NSDictionary *)properties {
    if ((self = [super init])) {
        self.name = name;
        if (properties[JMRIItemComment] != [NSNull null]) {
            self.comment = properties[JMRIItemComment];
        }
        if (properties[JMRIItemUserName] != [NSNull null]) {
            self.userName = properties[JMRIItemUserName];
        }
        self.inverted = [properties[JMRIItemInverted] boolValue];
        if (properties[JMRIItemState]) {
            _state = [properties[JMRIItemState] integerValue];
        } else if (properties[JMRIItemValue]) {
            _state = JMRIItemStateStateless;
            _value = properties[JMRIItemValue];
        } else {
            _state = JMRIItemStateUnknown;
        }
        self.service = service;
    }
    return self;
}

#pragma mark - Communications

- (void)query {
    if (self.service.hasJsonService && self.service.useJsonService) {
        [self queryFromJsonService:self.service.jsonService];
    } else if (self.service.hasWebService && self.service.useWebService) {
        [self queryFromWebService:self.service.webService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        // WiThrottle has no explicit query mechanism
    }
}

- (void)queryFromJsonService:(JsonService *)service {
    // silently do nothing if not supported by protocol
}

- (void)queryFromWebService:(WebService *)service {
    // silently do nothing if not supported by protocol
}

- (void)queryFromWiThrottleService:(WiThrottleService *)service {
    // silently do nothing if not supported by protocol
}

- (void)write {
    if (self.service.hasJsonService && self.service.useJsonService) {
        [self writeToJsonService:self.service.jsonService];
    } else if (self.service.hasWiThrottleService && self.service.useWiThrottleService) {
        [self writeToWiThrottleService:self.service.wiThrottleService];
    } else if (self.service.hasWebService && self.service.useWebService) {
        [self writeToWebService:self.service.webService];
    }
}

- (void)writeToJsonService:(JsonService *)service {
    //silently do nothing if not supported by protocol
}

- (void)writeToWebService:(WebService *)service {
    // silently do nothing if not supported by protocol
}

- (void)writeToWiThrottleService:(WiThrottleService *)service {
    // silently do nothing if not supported by protocol
}

#pragma mark - Properties

- (NSUInteger)state {
    return _state;
}

- (void)setState:(NSUInteger)state {
    [self setState:state updateService:YES];
}

- (void)setState:(NSUInteger)state updateService:(Boolean)update {
    if (_state != JMRIItemStateStateless && _state != state) {
        _state = state;
        if (update) {
            if (_state == JMRIItemStateUnknown || _state == JMRIBeanStateUnknown) {
                [self query];
            } else {
                [self write];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationStateChange object:self];
    }
}    

- (NSString *)value {
    if (self.state == JMRIItemStateStateless) {
        return _value;
    }
    return [[NSNumber numberWithInteger:self.state] stringValue];
}

- (void)setValue:(NSString *)value {
    [self setValue:value updateService:YES];
}

- (void)setValue:(NSString *)value updateService:(Boolean)update {
    if (self.state == JMRIItemStateStateless) {
        if (![_value isEqualToString:value]) {
            if ([value isEqualToString:@""]) {
                _value = nil;
            } else {
                _value = value;
            }
            if (update) {
                if (!_value) {
                    [self query];
                } else {
                    [self write];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:JMRINotificationStateChange object:self];
        }
    } else {
        [self setState:[value integerValue] updateService:update];
    }
}

- (void)setService:(JMRIService *)service {
    if (_service != nil) {
        [[_service valueForKey:[_service collectionForType:self.type]] removeObjectForKey:self.name];
    }
    _service = nil;
    _service = service;
    if (service != nil) {
        [[service valueForKey:[service collectionForType:self.type]] setValue:self forKey:self.name];
        [service item:self addedToList:[service valueForKey:[service collectionForType:self.type]]];
    }
}

- (NSString *)type {
    [self doesNotRecognizeSelector:_cmd];
    return @"";
}

@synthesize comment = _comment;
@synthesize inverted = _inverted;
@synthesize name = _name;
@synthesize service = _service;
@synthesize userName = _userName;

- (NSDictionary *)properties {
    if (self.state == JMRIItemStateStateless) {
        return @{JMRIItemName: (self.name) ? self.name : [NSNull null],
                 JMRIItemComment: (self.comment) ? self.comment : [NSNull null],
                 JMRIItemValue: (self.value) ? self.value : [NSNull null],
                 JMRIItemUserName: (self.userName) ? self.userName : [NSNull null]};
    } else {
        return @{JMRIItemName: (self.name) ? self.name : [NSNull null],
                 JMRIItemComment: (self.comment) ? self.comment : [NSNull null],
                 JMRIItemState: [NSNumber numberWithInteger:self.state],
                 JMRIItemUserName: (self.userName) ? self.userName : [NSNull null]};
    }
}

#pragma mark - Utilities

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIItem *)item {
	if (self.userName && item.userName) {
		return [self.userName localizedCaseInsensitiveCompare:item.userName];
	} else if (self.userName && item.name) {
		return [self.userName localizedCaseInsensitiveCompare:item.name];
 	} else if (self.name && item.userName) {
		return [self.name localizedCaseInsensitiveCompare:item.userName];
	}
	return [self.name localizedCaseInsensitiveCompare:item.name];
}

@end
