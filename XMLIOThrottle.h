/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOThrottle.h
//  JMRI Framework
//
//  Created by Randall Wood on 31/5/2011.
//

#import "XMLIOObject.h"
#import "XMLIOFunction.h"

@class XMLIOService;

@interface XMLIOThrottle : XMLIOObject {

    NSUInteger address_;
    NSString *forward;
    NSString *speed;
    XMLIOFunction *F0;
    XMLIOFunction *F1;
    XMLIOFunction *F2;
    XMLIOFunction *F3;
    XMLIOFunction *F4;
    XMLIOFunction *F5;
    XMLIOFunction *F6;
    XMLIOFunction *F7;
    XMLIOFunction *F8;
    XMLIOFunction *F9;
    XMLIOFunction *F10;
    XMLIOFunction *F11;
    XMLIOFunction *F12;
    
    XMLIOService *service_;
    
}

- (id)initWithAddress:(NSUInteger)address withService:(XMLIOService *)service;

@property (readonly) NSUInteger address;
@property (nonatomic, retain) NSString *forward;
@property (nonatomic, retain) NSString *speed;
@property (nonatomic, retain) XMLIOFunction *F0;
@property (nonatomic, retain) XMLIOFunction *F1;
@property (nonatomic, retain) XMLIOFunction *F2;
@property (nonatomic, retain) XMLIOFunction *F3;
@property (nonatomic, retain) XMLIOFunction *F4;
@property (nonatomic, retain) XMLIOFunction *F5;
@property (nonatomic, retain) XMLIOFunction *F6;
@property (nonatomic, retain) XMLIOFunction *F7;
@property (nonatomic, retain) XMLIOFunction *F8;
@property (nonatomic, retain) XMLIOFunction *F9;
@property (nonatomic, retain) XMLIOFunction *F10;
@property (nonatomic, retain) XMLIOFunction *F11;
@property (nonatomic, retain) XMLIOFunction *F12;

@property (nonatomic, retain) XMLIOService *service;

@end
