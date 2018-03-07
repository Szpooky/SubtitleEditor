//
//  SENode.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SENode.h"

@implementation SENode

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        self.error = 0;
        self.textProblem = NO;
        self.boxView = nil;
        self.text = nil;
        self.selected = NO;
    }
    return self;
}

- (NSString*)stringValue
{
    return [NSString stringWithFormat:@"%@ --> %@\n%@\n\n",NSStringFromSETime(SETimeFromCMTime(CMTimeMakeWithSeconds(self.startTime, 1000))), NSStringFromSETime(SETimeFromCMTime(CMTimeMakeWithSeconds(self.endTime, 1000))),(_text || [_text isEqualToString:@""]) ? _text : @" "];
}

- (BOOL)conflictWithNode:(SENode*)node
{
    NSUInteger retVal = 0;
    
    if(node)
    {
        double start1 = self.startTime;
        double end1 = self.endTime;
        double start2 = node.startTime;
        double end2 = node.endTime;
        double minDistance = [SESingleton shared].errorSlider.doubleValue * 1.0;
        
        //level 1: warning
        if((start1 <= start2 && abs((int)end1 - (int)start2) < minDistance) || (start2 <= start1 && abs((int)end2 - (int)start1) < minDistance))
        {
            retVal = 1;
        }
        
        //level 2: error
        if((start2 <= end1 && start2 >= start1) || (end2 <= end1 && end2 >= start1)
           || (start1 < end2 && start1 > start2) || (end1 <= end2 && end1 >= start2))
        {
            retVal = 2;
        }
        
        if(retVal > 0)
        {
            if(retVal > self.error)
            {
                self.error = retVal;
            }
            
            if(retVal > node.error)
            {
                node.error = retVal;
            }
        }
    }
    
    //check text
    if(self.text == nil || [self.text isEqualToString:@""])
    {
        retVal = 2;
        if(retVal > self.error)
        {
            self.error = retVal;
        }
    }
    
    if(node)
    {
        if(node.text == nil || [node.text isEqualToString:@""])
        {
            retVal = 2;
            if(retVal > node.error)
            {
                node.error = retVal;
            }
        }
    }
    return retVal;
}

- (void)dealloc
{
    self.text = nil;
}

@end
