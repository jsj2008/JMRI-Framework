//
//  NSMutableArray_QueueExtensions.h
//  JMRI Framework
//
//  Created by Randall Wood on 10/3/2013.
//
//  from https://github.com/esromneb/ios-queue-object/

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueExtensions)

- (id)dequeue;
- (void)enqueue:(id)object;

- (id)peek:(int)index;
- (id)peekHead;
- (id)peekTail;
- (BOOL)isEmpty;

@end
