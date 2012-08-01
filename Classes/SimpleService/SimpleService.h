//
//  SimpleService.h
//  JMRI Framework
//
//  Created by Randall Wood on 28/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import "JMRINetService.h"

@interface SimpleService : JMRINetService <NSStreamDelegate> {

    NSInputStream* inputStream;
    NSOutputStream* outputStream;

}

- (void)openConnection;
- (void)closeConnection;

- (void)write:(NSString *)string;

@end

#pragma mark - Delegate protocol

@protocol SimpleServiceDelegate <JMRINetServiceDelegate>

#pragma mark Required Methods

@required
- (void)simpleService:(SimpleService *)service didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)simpleService:(SimpleService *)service didGetInput:(NSString *)input;
- (void)simpleServiceDidOpenConnection:(SimpleService *)service;

@end