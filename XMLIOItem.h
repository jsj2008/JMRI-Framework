/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  XMLIOItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 26/5/2011.
//

#import <Foundation/Foundation.h>
#import "XMLIOObject.h"

@class JMRIItem;
@class JMRIService;

@interface XMLIOItem : XMLIOObject <NSCoding> {

    NSString *systemName;   // name
    NSString *type;         // type
    NSString *userName;     // userName
    NSString *value;        // state
    NSString *comment;      // comment
    BOOL inverted;          // inverted

    // roster-only elements are needed in XMLIOItem for JMRI < 2.13.1
    NSUInteger dccAddress;
    NSString *addressLength;
    NSString *roadName;
    NSString *roadNumber;
    NSString *mfg;
    NSString *model;
    float maxSpeedPct;
    NSString *imageFileName;
    NSString *imageIconName;
    NSMutableArray *functions;
    
}

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(XMLIOItem *)item;

# pragma mark Standard properties

@property (nonatomic) NSString* name;
@property (nonatomic) NSString* type;
@property (nonatomic) NSString* userName;
@property (nonatomic) NSString* value;
@property (nonatomic) NSString* comment;
@property (nonatomic) BOOL inverted;

#pragma mark Object properties

@property (readonly) NSDictionary *properties;

#pragma mark Roster properties

@property (nonatomic) NSUInteger dccAddress;
@property (nonatomic) NSString* addressLength;
@property (nonatomic) NSString* roadName;
@property (nonatomic) NSString* roadNumber;
@property (nonatomic) NSString* mfg;
@property (nonatomic) NSString* model;
@property (nonatomic) float maxSpeedPct;
@property (nonatomic) NSString* imageFileName;
@property (nonatomic) NSString* imageIconName;
@property  NSMutableArray* functions;

@end
