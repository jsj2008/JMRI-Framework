//
//  NSStream+JMRIExtensions.h
//  JMRI-Framework
//
//  Created by Randall Wood on 29/10/2011.
//  Copyright (c) 2011 Alexandria Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (JMRIExtensions)

+ (void)getStreamsToHostNamed:(NSString *)hostName 
                         port:(unsigned int)port
                  inputStream:(NSInputStream **)inputStreamPtr 
                 outputStream:(NSOutputStream **)outputStreamPtr;

@end
