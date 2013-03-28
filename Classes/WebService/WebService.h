//
//  WebService.h
//  JMRI Framework
//
//  Created by Randall Wood on 28/3/2013.
//
//

#import "JMRINetService.h"
#define JMRI_WEB_JSON_RECOMMENDED_VERSION @"3.3.4"

@class JMRIItem;

@interface WebService : JMRINetService {

    NSUInteger _openConnections;
    NSDictionary *collections;

}

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;
- (void)writeItem:(JMRIItem *)item;
- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state;
- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)createItem:(JMRIItem *)item;

#pragma mark - Properties

@property (readonly) NSURL* url;
@property (strong) NSString *JSONPath;
@property (readonly) NSUInteger openConnections;

@end
