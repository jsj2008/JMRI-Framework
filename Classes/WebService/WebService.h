//
//  WebService.h
//  JMRI Framework
//
//  Created by Randall Wood on 28/3/2013.
//
//

#import <JMRI/JMRI.h>
#define JMRI_WEB_JSON_RECOMMENDED_VERSION @"3.3.4"

@interface WebService : JMRINetService {

    NSUInteger _openConnections;

}

- (void)list:(NSString *)type;
- (void)readItem:(NSString *)name ofType:(NSString *)type;
- (void)writeItem:(NSString *)name ofType:(NSString *)type value:(NSString *)value;
- (void)writeItem:(NSString *)name ofType:(NSString *)type state:(NSUInteger)state;

#pragma mark - Properties

@property (readonly) NSURL* url;
@property (strong) NSString *JSONPath;
@property (readonly) NSUInteger openConnections;

@end
