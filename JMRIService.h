//
//  JMRIService.h
//  JMRI Framework
//
//  Created by Randall Wood on 2/5/2012.
//  Copyright (c) 2012 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMRIService : NSObject

#pragma mark - Initialization

- (id)initWithAddress:(NSString *)address withPorts:(NSDictionary *)ports;
- (id)initWithWebServices:(NSDictionary *)services;

@end