//
//  WebService.h
//  JMRI Framework
//
//  Created by Randall Wood on 28/3/2013.
//
//

#import "JMRINetService.h"
#define JMRI_WEB_RECOMMENDED_VERSION @"3.3.6"
#define JMRI_JSON_RECOMMENDED_VERSION @"0.1"

@class JMRIItem;

@interface WebService : JMRINetService {

    NSUInteger _openConnections;

}

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;
- (void)writeItem:(JMRIItem *)item ofType:(NSString *)type;
- (void)createItem:(NSString *)name ofType:(NSString *)type withState:(NSUInteger)state;
- (void)createItem:(NSString *)name ofType:(NSString *)type withValue:(NSString *)value;
- (void)createItem:(JMRIItem *)item ofType:(NSString *)type;

#pragma mark - Properties

@property (readonly) NSURL* url;
@property (strong) NSString *JSONPath;
@property (readonly) NSUInteger openConnections;

@end
