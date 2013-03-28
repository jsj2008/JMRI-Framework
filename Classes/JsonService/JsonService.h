//
//  JsonService.h
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JMRINetService.h"
#define MIN_JSON_VERSION @"3.2"

@interface JsonService : JMRINetService <NSStreamDelegate> {
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableArray *outputQueue;
    
}

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;

@property Boolean useQueue;

@end