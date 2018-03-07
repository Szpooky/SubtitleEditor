//
//  SEUtils.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEUtils.h"

NSUInteger milliSecondFromTime(SETime time)
{
    NSUInteger retVal = 0;
    
    retVal += time.msecond;
    retVal += time.second * 1000;
    retVal += time.minute * 1000 * 60;
    retVal += time.hour * 1000 * 3600;
    
    return retVal;
}

SETime createTime(int hour, int minute, int second, int msecond)
{
    SETime retVal;
    
    retVal.hour = hour;
    retVal.minute = minute;
    retVal.second = second;
    retVal.msecond = msecond;
    
    retVal.msecondValue = milliSecondFromTime(retVal);
    
    return retVal;
}

SETime createTimeFromMilliSecond(long msecond)
{
    SETime retVal;
    
    long temp = msecond;
    retVal.hour = (int)(temp / (1000 * 3600));
    temp = (long)(temp % (1000 * 3600));
    retVal.minute = (int)(temp / (1000 * 60));
    temp = (long)(temp % (1000 * 60));
    retVal.second = (int)(temp / 1000);
    temp = (long)(temp % 1000);
    retVal.msecond = (int)temp;
    
    retVal.msecondValue = msecond;
    
    return retVal;
}

NSString* NSStringFromSETime(SETime time)
{
    return [NSString stringWithFormat:@"%02d:%02d:%02d,%03d",time.hour, time.minute, time.second, time.msecond];
}

SETime SETimeFromCMTime(CMTime time)
{
    SETime retVal;
    
    long long frame;
    long long result;
    
    
    
    // timeScale is fps * 100
    result = time.value / (long long)time.timescale; // second
    frame = (time.value % (long long)time.timescale);
    
    int sec = (int)(result % 60);
    
    //scale the msecond to correct value
    CGFloat tempFrame = (CGFloat)frame;
    CGFloat tempScale = (CGFloat)time.timescale;
    CGFloat newFrame = 1000.0 / tempScale * tempFrame;
    
    retVal.msecond = (int)newFrame;
    retVal.second = sec;
    
    result = result / 60; // minute
    retVal.minute = (int)(result % 60);
    
    result = result / 60; // hour
    retVal.hour = (int)(result % 24);
    
    retVal.msecondValue = milliSecondFromTime(retVal);
    
    return retVal;
}

BOOL NSRectIntersection(NSRect frame1, NSRect frame2)
{
    NSPoint p1 = frame2.origin;
    NSPoint p2 = NSMakePoint(frame2.origin.x + frame2.size.width, frame2.origin.y);
    return NSPointInRect(p1, frame1) || NSPointInRect(p2, frame1) || (p1.x < frame1.origin.x && p2.x > frame1.origin.x + frame1.size.width);
}


@implementation NSString (RegExpExtensions)

- (BOOL)doesMatchRegStringExp:(NSString *)string
{
    NSPredicate *regExpPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", string];
    return [regExpPredicate evaluateWithObject:self];
}

@end


@implementation SEUtils

@end
