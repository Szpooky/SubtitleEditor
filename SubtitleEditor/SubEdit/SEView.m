//
//  SEView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEView.h"

@implementation SEView

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if(self.backgroundColor)
    {
        [self.backgroundColor setFill];
        NSRectFill(dirtyRect);
    }
    
    if (_highlighted)
    {
        [[NSColor greenColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: dirtyRect];
    }
}


#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    BOOL retVal = NSDragOperationNone;
    if ( [sender draggingSourceOperationMask] & NSDragOperationCopy )
    {
        _highlighted = YES;
        [self setNeedsDisplay:YES];
        retVal = NSDragOperationCopy;
    }
    
    return retVal;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlighted = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    _highlighted = NO;
    [self setNeedsDisplay:YES];
    
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ([sender draggingSource] != self)
    {
        NSURL* fileURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
        NSString* path = [fileURL path];
        
        BOOL valid = NO;
        for(NSString* ext in self.allowedFileExtensions)
        {
            if([ext isEqualToString:[[path pathExtension] lowercaseString]])
            {
                valid = YES;
                break;
            }
        }
        
        if(valid && self.draggingCompletionBlock)
        {
            self.draggingCompletionBlock(fileURL);
        }
    }
    
    return YES;
}

@end

