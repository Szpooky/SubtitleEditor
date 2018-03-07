//
//  SETextView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SETextView.h"

@implementation SETextView

- (BOOL)shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textViewShouldChangeText:)])
        {
            [self.delegate performSelector:@selector(textViewShouldChangeText:) withObject:self];
        }
    }
    return YES;
}

- (void)didChangeText
{
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textViewDidChangeText:)])
        {
            [self.delegate performSelector:@selector(textViewDidChangeText:) withObject:self];
        }
    }
}

- (void)cut:(id)sender
{
    [super cut:sender];
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textViewKeyDown:)])
        {
            [self.delegate performSelector:@selector(textViewKeyDown:) withObject:self];
        }
    }
}

- (void)paste:(id)sender
{
    [super paste:sender];
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textViewKeyDown:)])
        {
            [self.delegate performSelector:@selector(textViewKeyDown:) withObject:self];
        }
    }
}


- (void)keyUp:(NSEvent *)pEvent
{
    if(self.delegate != nil)
    {
        if([self.delegate respondsToSelector:@selector(textViewKeyDown:)])
        {
            [self.delegate performSelector:@selector(textViewKeyDown:) withObject:self];
        }
    }
    [super keyUp: pEvent];
}

@end
