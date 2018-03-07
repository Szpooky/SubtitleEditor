//
//  SEUtils.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef struct SETime
{
    int     hour, minute,second,msecond;
    long    msecondValue;
    
}SETime;


SETime createTime(int hour, int minute, int second, int msecond);
SETime createTimeFromMilliSecond(long msecond);
NSUInteger milliSecondFromTime(SETime time);
NSString* NSStringFromSETime(SETime time);
SETime SETimeFromCMTime(CMTime time);
BOOL NSRectIntersection(NSRect frame1, NSRect frame2);



@interface NSString (RegExpExtensions)

- (BOOL)doesMatchRegStringExp:(NSString *)string;

@end


@interface SEUtils : NSObject

@end
