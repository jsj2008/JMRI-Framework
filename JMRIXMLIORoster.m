/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIXMLIORoster.m
//  JMRI Framework
//
//  Created by Randall Wood on 31/5/2011.
//

#import "JMRIXMLIORoster.h"

@implementation JMRIXMLIORoster

@synthesize functions = functions_;

- (id)init {
	if ((self = [super init])) {
        self.functions = [NSMutableArray arrayWithCapacity:13];
        for (NSUInteger i = 0; i < [self.functions count]; i++) {
            [self.functions insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                             [@"F" stringByAppendingString:[[NSNumber numberWithUnsignedInteger:i] stringValue]], 
                                             @"label",
                                             [NSNumber numberWithBool:YES],
                                             @"lockable",
                                             nil] atIndex:i];
        }
	}
	return self;
}

- (NSString *)labelForFunction:(NSInteger)function {
    return [[self.functions objectAtIndex:function] objectForKey:@"label"];
}

- (BOOL)lockableForFunction:(NSInteger)function {
    return [[[self.functions objectAtIndex:function] objectForKey:@"lockable"] boolValue];
}

- (void)dealloc {
    self.functions = nil;
	[super dealloc];
}

@end
