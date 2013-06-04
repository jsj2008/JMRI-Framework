//
//  JsonService.h
//  JMRI Framework
//
//  Created by Randall Wood on 3/3/2013.
//
//

#import "JMRINetService.h"
#define MIN_JSON_VERSION @"3.3.6"

@class JMRIItem;

@interface JsonService : JMRINetService <NSStreamDelegate> {
    
    NSInputStream *inputStream;
    NSOutputStream *outputStream;
    NSMutableArray *outputQueue;
    
}

- (id)initWithName:(NSString *)name withURL:(NSURL *)URL;

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;
- (void)writeItem:(JMRIItem *)item;
- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state;
- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)createItem:(JMRIItem *)item;

@property (readonly) Boolean isOpening;
@property Boolean useQueue;
@property (strong) NSURL* webSocketURL;

@end