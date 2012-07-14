//
//  SimpleService.h
//  JMRI Framework
//
//  Created by Randall Wood on 28/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "JMRINetService.h"

@interface SimpleService : JMRINetService <NSStreamDelegate> {

    NSInputStream* input;
    NSOutputStream* output;

}

- (void)write:(NSString *)string;

- (void)openConnection;
- (void)closeConnection;

@end

#pragma mark - Delegate protocol

@protocol SimpleServiceDelegate <JMRINetServiceDelegate>

#pragma mark Required Methods

@required
- (void)simpleService:(SimpleService *)service didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)simpleService:(SimpleService *)service didReadItemNamed:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)simpleService:(SimpleService *)service didWriteItemNamed:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;

@end