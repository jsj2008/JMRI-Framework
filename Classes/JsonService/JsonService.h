//
//  JsonService.h
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JMRINetService.h"

@interface JsonService : JMRINetService <NSStreamDelegate> {
    
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
    
}

- (void)openConnection;
- (void)closeConnection;

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type initialValue:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;

@end

#pragma mark - Delegate protocol

@protocol JsonServiceDelegate <JMRINetServiceDelegate>

#pragma mark Required Methods

@required
- (void)jsonService:(JsonService *)service didFailWithError:(NSError *)error;

#pragma mark Optional Methods

@optional
- (void)jsonService:(JsonService *)service didGetInput:(NSDictionary *)input;
- (void)jsonServiceDidOpenConnection:(JsonService *)service;

@end