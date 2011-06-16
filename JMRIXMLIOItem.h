/*
 Copyright 2011 Randall Wood DBA Alexandria Software at http://www.alexandriasoftware.com. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 2.  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 3.  The name of the author may not be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  JMRIXMLIOItem.h
//  JMRI Framework
//
//  Created by Randall Wood on 26/5/2011.
//

#import <Foundation/Foundation.h>
#import "JMRIXMLIOObject.h"

@interface JMRIXMLIOItem : JMRIXMLIOObject {

}

- (NSComparisonResult)localizedCaseInsensitiveCompareByUserName:(JMRIXMLIOItem*)item;

# pragma mark Standard properties

@property (nonatomic, retain) NSString* type;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* value;
@property (nonatomic, retain) NSString* comment;
@property (nonatomic, retain) NSString* inverted;

#pragma mark Roster properties

@property (nonatomic, retain) NSString* dccAddress;
@property (nonatomic, retain) NSString* addressLength;
@property (nonatomic, retain) NSString* roadName;
@property (nonatomic, retain) NSString* roadNumber;
@property (nonatomic, retain) NSString* mfg;
@property (nonatomic, retain) NSString* model;
@property (nonatomic, retain) NSString* maxSpeedPct;
@property (nonatomic, retain) NSString* imageFileName;
@property (nonatomic, retain) NSString* imageIconName;
@property (nonatomic, retain) NSString* functionLabels;
@property (nonatomic, retain) NSString* functionLockables;

@end
