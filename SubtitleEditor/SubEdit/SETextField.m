//
//  SETextField.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SETextField.h"

@implementation SETextField

- (void)setStringValue:(NSString *)aString
{
    [super setStringValue:aString];
    NSString* regex = @"(\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3}) --> (\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3})";
    if([aString doesMatchRegStringExp:regex] || !aString || [aString isEqualToString:@""])
    {
        [self setBackgroundColor:[NSColor lightGrayColor]];
    }
    else
    {
        [self setBackgroundColor:[NSColor lightGrayColor]];
    }
}

- (void)keyUp:(NSEvent *)pEvent
{
    [super keyUp: pEvent];
    
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textFieldKeyDown:)])
        {
            [self.delegate performSelector:@selector(textFieldKeyDown:) withObject:self];
        }
    }
    
    NSString* regex = @"(\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3}) --> (\\d{1,2}):(\\d{1,2}):(\\d{1,2}),(\\d{1,3})";
    if([self.stringValue doesMatchRegStringExp:regex] || !self.stringValue || [self.stringValue isEqualToString:@""])
    {
        [self setBackgroundColor:[NSColor lightGrayColor]];
    }
    else
    {
        [self setBackgroundColor:[NSColor lightGrayColor]];
    }
}

@end
