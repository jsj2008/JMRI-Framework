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
