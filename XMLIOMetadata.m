/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIORoster.m
//  JMRI Framework
//
//  Created by Randall Wood on 31/5/2011.
//

#import "XMLIOMetadata.h"
#import "JMRIMetadata.h"

@implementation XMLIOMetadata

@synthesize majorVersion;
@synthesize minorVersion;
@synthesize testVersion;

- (id) init {
    if ((self = [super init])) {
        majorVersion = 0;
        minorVersion = 0;
        testVersion = 0;
    }
    return self;
}

- (JMRIItem *)JMRIItemForService:(JMRIService *)service {
    JMRIMetadata *m = [[JMRIMetadata alloc] initWithName:self.name withService:service];
    m.value = self.value;
    m.userName = self.userName;
    m.comment = self.comment;
    m.majorVersion = self.majorVersion;
    m.minorVersion = self.minorVersion;
    m.testVersion = self.testVersion;
    return m;
}

@end