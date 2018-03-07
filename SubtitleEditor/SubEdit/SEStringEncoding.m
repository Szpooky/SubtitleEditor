//
//  SEStringEncoding.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEStringEncoding.h"
#import "SEUtils.h"
#import "SENode.h"

#define SE_END_STRING_SIGN @"\n\n\n<qqq35gtggj///(end)///1asdfjahgsdlfjh8362364572635478123764ffakghsdkvkhashvadhsfvhjadsv>"

typedef struct SEDuration
{
    SETime      start;
    SETime      end;
    BOOL        valid;
    
}SEDuration;

@implementation SEStringEncoding

+ (NSMutableArray*)encodingArray
{
    NSMutableArray* retVal = [NSMutableArray arrayWithObjects:
                              [NSNumber numberWithInt:NSWindowsCP1250StringEncoding],
                              [NSNumber numberWithInt:NSUTF8StringEncoding],
                              [NSNumber numberWithInt:NSASCIIStringEncoding],
                              [NSNumber numberWithInt:NSISOLatin1StringEncoding],
                              [NSNumber numberWithInt:NSShiftJISStringEncoding],
                              [NSNumber numberWithInt:NSISOLatin2StringEncoding],
                              [NSNumber numberWithInt:NSWindowsCP1251StringEncoding],
                              [NSNumber numberWithInt:NSWindowsCP1252StringEncoding],
                              [NSNumber numberWithInt:NSWindowsCP1253StringEncoding],
                              [NSNumber numberWithInt:NSWindowsCP1254StringEncoding],
                              //[NSNumber numberWithInt:NSUnicodeStringEncoding],
                              [NSNumber numberWithInt:NSUTF16StringEncoding],
                              [NSNumber numberWithInt:NSNEXTSTEPStringEncoding],
                              [NSNumber numberWithInt:NSMacOSRomanStringEncoding],
                              [NSNumber numberWithInt:NSJapaneseEUCStringEncoding],
                              [NSNumber numberWithInt:NSSymbolStringEncoding],
                              [NSNumber numberWithInt:NSNonLossyASCIIStringEncoding],
                              [NSNumber numberWithInt:NSISO2022JPStringEncoding],
                              nil];
    
    return retVal;
}

+ (NSInteger)indexOfEncoding:(NSStringEncoding)encoding inArray:(NSArray*)array
{
    NSInteger retVal = -1;
    if(array != nil)
    {
        for (NSInteger i = 0; i < [array count]; i++)
        {
            NSStringEncoding value = (NSStringEncoding)[[array objectAtIndex:i] intValue];
            if(value == encoding)
            {
                retVal = i;
                break;
            }
        }

    }
    return retVal;
}

+ (SEDuration)durationFromString:(NSString*)string
{
    SEDuration retTime;
    retTime.valid = NO;
    
    NSArray* words = [string componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceCharacterSet]];
    NSString* time = [words componentsJoinedByString:@""];
    NSArray* timeArray = [time componentsSeparatedByString:@"-->"];
    if([timeArray count] == 2)
    {
        NSString* start = [timeArray objectAtIndex:0];
        NSString* end = [timeArray objectAtIndex:1];
        
        NSArray* hourArray = [start componentsSeparatedByString:@":"];
        int hour = [[hourArray objectAtIndex:0] intValue];
        int minute = [[hourArray objectAtIndex:1] intValue];
        NSArray* secondArray = [[hourArray objectAtIndex:2] componentsSeparatedByString:@","];
        int second = [[secondArray objectAtIndex:0] intValue];
        int msecond = [[secondArray objectAtIndex:1] intValue];
        
        retTime.start = createTime(hour, minute,second,msecond);
        
        NSArray* hourArray2 = [end componentsSeparatedByString:@":"];
        int hour2 = [[hourArray2 objectAtIndex:0] intValue];
        int minute2 = [[hourArray2 objectAtIndex:1] intValue];
        NSArray* secondArray2 = [[hourArray2 objectAtIndex:2] componentsSeparatedByString:@","];
        int second2 = [[secondArray2 objectAtIndex:0] intValue];
        int msecond2 = [[secondArray2 objectAtIndex:1] intValue];
        
        retTime.end = createTime(hour2, minute2,second2,msecond2);
        
        retTime.valid = YES;
    }
    
    return retTime;
}

+ (NSString*)preproccessSubtitle:(NSString*)subtitle toArray:(NSMutableArray*)array
{
    if(array == nil)
    {
        return @"Allocation error. Please Try again, or restart the program!";
    }
    
    NSString* retVal = nil;
    NSString* tempString = [NSString stringWithFormat:@"%@\n%@",subtitle,SE_END_STRING_SIGN];
    [array removeAllObjects];
    NSArray* lines = [tempString componentsSeparatedByString:@"\n"];
    
    for(NSString* oneLine in lines)
    {
        NSUInteger index = [lines indexOfObject:oneLine];
        
        //remove some bad character
        NSArray* words = [oneLine componentsSeparatedByCharactersInSet:[NSCharacterSet controlCharacterSet]];
        NSString* line = [words componentsJoinedByString:@""];
        
        
        NSString* regex =  @"[0-9]+";
        if([line doesMatchRegStringExp:regex])
        {

            //remove some bad character
            NSString* timeLine = [lines objectAtIndex:(index+1)];
            NSArray* timeWords = [timeLine componentsSeparatedByCharactersInSet :[NSCharacterSet controlCharacterSet]];
            timeLine = [timeWords componentsJoinedByString:@""];
            
            regex = @"(\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3}) --> (\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3})";
            if([timeLine doesMatchRegStringExp:regex])
            {
                SEDuration time = [SEStringEncoding durationFromString:timeLine];
                if(time.valid)
                {
                    //read the subtitle
                    SENode* node = [[SENode alloc] init];
                    
                    NSMutableString* subtitle = [NSMutableString string];
                    for(NSUInteger i = index + 2 ; i < [lines count] ; i++)
                    {
                         //remove some bad character
                        NSString* l = [lines objectAtIndex:i];
                        NSArray* lWords = [l componentsSeparatedByCharactersInSet :[NSCharacterSet controlCharacterSet]];
                        l = [lWords componentsJoinedByString:@""];
                        
                        if([l isEqualToString:@""])
                        {
                            break;
                        }
                        else
                        {
                            [subtitle appendString:l];
                            [subtitle appendString:@"\n"];
                        }
                    }
                    
                    //remove SE_END_STRING_SIGN
                    //NSString* tempString1 = [subtitle stringByReplacingOccurrencesOfString:SE_END_STRING_SIGN withString:@"--End--"];
                                        
                    //remove last enter
                    NSString* tempString = [NSString stringWithFormat:@"%@",subtitle];
                    [subtitle setString:@""];
                    NSArray* a = [tempString componentsSeparatedByString:@"\n"];
                    for(int i = 0 ; i < [a count] - 1 ; i++)
                    {
                        [subtitle appendString:[a objectAtIndex:i]];
                        if(i  < [a count] - 2)
                        {
                            [subtitle appendString:@"\n"];
                        }
                    }//*/
                    
                    node.textProblem = NO;
                    node.startTime = (double)time.start.msecondValue / 1000.0;
                    node.endTime = (double)time.end.msecondValue / 1000.0;
                    //node.duration = time;
                    if(subtitle)
                    {
                        node.text = [NSString stringWithFormat:@"%@",subtitle];
                    }
                    else
                    {
                        node.text = @"";
                    }
                    [array addObject:node];
                }
            }
        }
    }
    
    return retVal;
}

@end
