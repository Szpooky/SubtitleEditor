//
//  SESubtitleBoxView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SESubtitleBoxView.h"
#import "SELoadSubtitleWindow.h"
#import "SEAppDelegate.h"
#import "SEUtils.h"
#import "SEContentView.h"
#import "SEMoviewView.h"
#import "SENode.h"
#import "SETimeLineView.h"

@implementation SESubtitleBoxView
{
    NSTextField*        _label;
    CGFloat             _labelOffset;
    CGFloat             _temp;
    BOOL                _dragged;
    NSUInteger          _lineNum;
    NSImageView*        _warning;
    NSImageView*        _error;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        [self setAutoresizesSubviews:YES];
        [self setAutoresizingMask:NSViewMinXMargin];
        
        _labelOffset = 25.0;
        _label = [[NSTextField alloc] initWithFrame:NSInsetRect(self.bounds,_labelOffset, 3.0)];
        [_label setAutoresizingMask:NSViewWidthSizable];
        [_label setBackgroundColor:[NSColor clearColor]];
        [_label setAlignment:NSTextAlignmentCenter];
        [_label setEditable:NO];
        [_label setTextColor:[NSColor whiteColor]];
        [_label setBordered:NO];
        _label.font = [NSFont fontWithName:@"Verdana-Bold" size:self.frame.size.height - 15.0];
        [self addSubview:_label];
        
        _warning = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 0, BOX_HEIGHT, BOX_HEIGHT)];
        [_warning setImage:[NSImage imageNamed:@"warning_pics"]];
        [self addSubview:_warning];
        [_warning setHidden:YES];
        
        _error = [[NSImageView alloc] initWithFrame:NSMakeRect(10, 0, BOX_HEIGHT, BOX_HEIGHT)];
        [_error setImage:[NSImage imageNamed:@"error_pics"]];
        [self addSubview:_error];
        [_error setHidden:YES];
    }
    return self;
}

- (BOOL) acceptsFirstMouse:(NSEvent *)e
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (void)update
{
    _lineNum = 1;
    
    if(self.node)
    {
        if(self.node.text)
        {
            _lineNum = [[self.node.text componentsSeparatedByString:@"\n"] count];
            if(_lineNum > 4)
            {
                _lineNum = 4;
            }
            [self setFrameSize:NSMakeSize(self.frame.size.width, BOX_HEIGHT * _lineNum)];
            [_label setStringValue:self.node.text];
        }
        else
        {
            [_label setStringValue:@""];
        }
    }
    else
    {
        [_label setStringValue:@""];
    }
    [_label setFrame:NSInsetRect(self.bounds,_labelOffset, 3.0)];
    [self setNeedsDisplay:YES];
}

- (void)updateError
{
    if(self.node)
    {
        [_warning resignFirstResponder];
        [_error resignFirstResponder];
        [_warning setHidden:(self.node.error != 1)];
        [_error setHidden:(self.node.error != 2)];
    }
    else
    {
        [_warning setHidden:YES];
        [_error setHidden:YES];
    }
    
    [self becomeFirstResponder];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSRect startFrame = NSMakeRect(0.0, 0.0, _labelOffset, self.frame.size.height);
    NSRect endFrame = NSMakeRect(self.frame.size.width - _labelOffset, 0.0, _labelOffset, self.frame.size.height);
    
    if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], _label.frame))
    {
        self.dragType = DragTypeCenter;
    }
    else if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], startFrame))
    {
        self.dragType = DragTypeLeft;
    }
    else if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], endFrame))
    {
        self.dragType = DragTypeRight;
    }
    else
    {
        self.dragType = DragTypeNone;
    }
    
    _dragged = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if([SESingleton shared].currentNode)
    {
        [[SESingleton shared] setCurrentNode:nil];
    }
    
    _dragged = YES;
    
    if(self.node)
    {
        if (self.dragType == DragTypeCenter)
        {
            double start = self.node.startTime;
            double end = self.node.endTime;
            
            start += theEvent.deltaX / 1000.0 * SPEED_SCALE;
            end += theEvent.deltaX / 1000.0 * SPEED_SCALE;
            
            if(start >= 0)
            {
                if([SESingleton shared].singleSelected)
                {
                    [self setFrameOrigin:NSMakePoint(self.frame.origin.x + theEvent.deltaX, BOX_ORIGIN_Y)];
                    
                    //move
                    self.node.startTime = start;
                    self.node.endTime = end;
                }
                else
                {
                    for(SENode* node in [SESingleton shared].content)
                    {
                        if(node.selected)
                        {
                            start = node.startTime;
                            end = node.endTime;
                            
                            start += theEvent.deltaX / 1000.0 * SPEED_SCALE;
                            end += theEvent.deltaX / 1000.0 * SPEED_SCALE;
                            
                            if(start >= 0)
                            {
                                //move
                                node.startTime = start;
                                node.endTime = end;
                                
                                if(node.boxView)
                                {
                                    SESubtitleBoxView* box = [node boxView];
                                    [box setFrameOrigin:NSMakePoint(box.frame.origin.x + theEvent.deltaX, BOX_ORIGIN_Y)];
                                }
                            }
                            else
                            {
                                break;
                            }
                        }
                    }
                }
            }
        }
        else if (self.dragType == DragTypeLeft)
        {
            if((self.frame.size.width - theEvent.deltaX) > 45.0)
            {
                double start = self.node.startTime;
                double end = self.node.endTime;
                start += theEvent.deltaX / 1000.0 * SPEED_SCALE;
                
                if(start >= 0.0)
                {
                    [self setFrameOrigin:NSMakePoint(self.frame.origin.x + theEvent.deltaX, BOX_ORIGIN_Y)];
                    [self setFrameSize:NSMakeSize(self.frame.size.width - theEvent.deltaX, self.frame.size.height)];
                    [_label setFrame:NSInsetRect(self.bounds,_labelOffset, 3.0)];
                    
                    self.node.startTime = start;
                    self.node.endTime = end;

                    if((CGFloat)start > [SESingleton shared].timeLineView.currentTime)
                    {
                        //[SESingleton shared].currentNode = nil;
                    }
                }
            }
        }
        else if (self.dragType == DragTypeRight)
        {
            if(self.frame.size.width + theEvent.deltaX > 45.0)
            {
                [self setFrameSize:NSMakeSize(self.frame.size.width + theEvent.deltaX, self.frame.size.height)];
                [_label setFrame:NSInsetRect(self.bounds,_labelOffset, 3.0)];
                
                double start = self.node.startTime;
                double end = self.node.endTime;
                end += theEvent.deltaX / 1000.0 * SPEED_SCALE;
                self.node.startTime = start;
                self.node.endTime = end;
                
                if((CGFloat)end < [SESingleton shared].timeLineView.currentTime)
                {
                    //[SESingleton shared].currentNode = nil;
                }
            }
        }
        else
        {
            //Do nothing
        }
    }
    
    if(self.node)
    {
        [[SESingleton shared] setTimeDetailWithNode:self.node]; //refresh time details on bottom right labels
    }
    
    if([SESingleton shared].checkOnFly.state)
    {
        [[SESingleton shared] detectVisibleConflict];
    }
    
    [[SESingleton shared].timeLineView update];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if(self.node)
    {
        if(_dragged == NO)
        {
            double start = self.node.startTime + (self.node.endTime - self.node.startTime) / 2.0;
            [[SESingleton shared] jumpToTime:start];
            
            [[SESingleton shared].movieView seekToSeconds:start];
            
            [[SESingleton shared].timeLineView update];
        }
        else
        {
            [[SESingleton shared] shortContentByTime];
        }
    }
    
    if(_dragged == YES)
    {
        [[SESingleton shared].timeLineView determineCurrentNode];
    }
    
    if(![SESingleton shared].checkOnFly.state)
    {
        [[SESingleton shared] detectVisibleConflict];
    }
    
    _dragged = NO;
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    _dragType = DragTypeNone;
    if(![SESingleton shared].singleSelected)
    {
        NSRect startFrame = NSMakeRect(0.0, 0.0, _labelOffset, self.frame.size.height);
        NSRect endFrame = NSMakeRect(self.frame.size.width - _labelOffset, 0.0, _labelOffset, self.frame.size.height);
        
        if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], startFrame))
        {
            self.dragType = DragTypeLeft;
        }
        else if (NSPointInRect([self convertPoint:[theEvent locationInWindow] fromView:nil], endFrame))
        {
            self.dragType = DragTypeRight;
        }
        else
        {
            self.dragType = DragTypeNone;
        }
    }
    
    _dragged = NO;
    _temp = self.frame.origin.x;
}

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    if([SESingleton shared].currentNode)
    {
        [[SESingleton shared] setCurrentNode:nil];
    }
    
    _dragType = DragTypeRightMouse;
    if([SESingleton shared].singleSelected)
    {
        [self setFrameOrigin:NSMakePoint(self.frame.origin.x, self.frame.origin.y + theEvent.deltaY)];
        self.dragType = DragTypeRightMouse;
        [self setNeedsDisplay:YES];
    }
    else
    {
        for(SENode* node in [SESingleton shared].content)
        {
            if(node.selected)
            {
                SESubtitleBoxView* box = node.boxView;
                if(box)
                {
                    [box setFrameOrigin:NSMakePoint(box.frame.origin.x, box.frame.origin.y + theEvent.deltaY)];
                    box.dragType = DragTypeRightMouse;
                    [box setNeedsDisplay:YES];
                }
            }
        }
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    CGFloat delta = fabs(self.frame.origin.y - BOX_ORIGIN_Y);
    
    if(_dragType == DragTypeNone && ![SESingleton shared].singleSelected)
    {
        if(self.node)
        {
            if([theEvent clickCount] == 1)
            {
                self.node.selected = !self.node.selected;
                [self setNeedsDisplay:YES];
            }
            else
            {
                
            }
        }
    }
    else if(_dragType == DragTypeLeft)
    {
        if(self.node)
        {
            NSUInteger index = [[SESingleton shared].content indexOfObject:self.node] - 1;
            if(index < [SESingleton shared].content.count)
            {
                SENode* node = [[SESingleton shared].content objectAtIndex:index];
                while (index < [SESingleton shared].content.count && node.selected != self.node.selected)
                {
                    node.selected = self.node.selected;
                    if(node.boxView)
                    {
                        [node.boxView setNeedsDisplay:YES];
                    }
                    index--;
                    if(index < [SESingleton shared].content.count)
                    {
                        node = [[SESingleton shared].content objectAtIndex:index];
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }
    else if(_dragType == DragTypeRight)
    {
        if(self.node)
        {
            NSUInteger index = [[SESingleton shared].content indexOfObject:self.node] + 1;
            if(index < [SESingleton shared].content.count)
            {
                SENode* node = [[SESingleton shared].content objectAtIndex:index];
                while (index < [SESingleton shared].content.count && node.selected != self.node.selected)
                {
                    node.selected = self.node.selected;
                    if(node.boxView)
                    {
                        [node.boxView setNeedsDisplay:YES];
                    }
                    index++;
                    if(index < [SESingleton shared].content.count)
                    {
                        node = [[SESingleton shared].content objectAtIndex:index];
                    }
                    else
                    {
                        break;
                    }
                }
            }
        }
    }
    else if (_dragType == DragTypeRightMouse)
    {
        if(delta < BOX_HEIGHT)
        {
            if([SESingleton shared].singleSelected)
            {
                [self setFrameOrigin:NSMakePoint(self.frame.origin.x, BOX_ORIGIN_Y)];
            }
            else
            {
                for(SENode* node in [SESingleton shared].content)
                {
                    if(node.selected)
                    {
                        SESubtitleBoxView* box = node.boxView;
                        if(box)
                        {
                            [box setFrameOrigin:NSMakePoint(box.frame.origin.x, BOX_ORIGIN_Y)];
                            [box setNeedsDisplay:YES];
                        }
                    }
                }
            }
        }
        else
        {
            if(self.node && [SESingleton shared].singleSelected)
            {
                //remove node and box
                
                if(self.node == [SESingleton shared].currentNode)
                {
                    [SESingleton shared].currentNode = nil;
                }
                [[SESingleton shared].content removeObject:self.node];
                self.node = nil;
                [self setHidden:YES];
            }
            else if(![SESingleton shared].singleSelected)
            {
                if([SESingleton shared].currentNode.selected)
                {
                    [[SESingleton shared] setCurrentNode:nil];
                }
                
                NSMutableArray* a = [NSMutableArray array];
                for(SENode* node in [SESingleton shared].content)
                {
                    if(node.selected)
                    {
                        [a addObject:node];
                        if(node.boxView)
                        {
                            [node.boxView setHidden:YES];
                        }
                        [node.boxView setNode:nil];
                        node.boxView = nil;
                    }
                }
                [[SESingleton shared].content removeObjectsInArray:a];
                
                [[SESingleton shared].timeLineView update];
            }
            else
            {
                //Do nothing
            }
        }
    }
    
    [[SESingleton shared].timeLineView determineCurrentNode];
    
    _temp = 0.0;
    _dragType = DragTypeNone;
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    _dragType = DragTypeNone;
    _temp = self.frame.origin.x;
}

- (void)otherMouseDragged:(NSEvent *)theEvent
{
    _dragType = DragTypeOtherMouse;
    [self setFrameOrigin:NSMakePoint(self.frame.origin.x + theEvent.deltaX, self.frame.origin.y + theEvent.deltaY)];
}

- (void)otherMouseUp:(NSEvent *)theEvent
{
    if(_dragType == DragTypeNone)
    {
        //Do nothing
    }
    else if(_dragType == DragTypeOtherMouse)
    {
        [self setFrameOrigin:NSMakePoint(_temp, BOX_ORIGIN_Y)];
    }
    else
    {
        //Do nothing
    }
    _temp = 0.0;
    _dragType = DragTypeNone;
}

- (void)drawRect:(NSRect)dirtyRect
{
    BOOL deletende = NO;
    CGFloat deleteInset = 0.0;
    if(_dragType == DragTypeRightMouse)
    {
        CGFloat delta = fabs(self.frame.origin.y - BOX_ORIGIN_Y);
        
        if(delta >= BOX_HEIGHT)
        {
            deletende = YES;
        }
    }
    
    CGFloat lineWidth = 2.0;
    
    [[NSColor darkGrayColor] set];
    if(self.node)
    {
        if(deletende)
        {
            [[NSColor redColor] set];
        }
        else if(self.node.selected && ![SESingleton shared].singleSelected)
        {
            [[NSColor blueColor] set];
        }
        else
        {
            //Do nothing yet
        }
        
        if([SESingleton shared].singleSelected)
        {
            if(self.node.error == 1)
            {
                //[[NSColor orangeColor] set];
            }
            else if(self.node.error == 2 || self.node.textProblem == YES)
            {
                //[[NSColor orangeColor] set];
            }
            else
            {
                
            }
            
        }
    }
    NSBezierPath* roundRectPath2 = [NSBezierPath bezierPathWithRoundedRect:dirtyRect xRadius:10 yRadius:10];
    [roundRectPath2 addClip];
    //NSRectFill(NSInsetRect(dirtyRect, 20.0,lineWidth));
    NSRectFill(dirtyRect);
    
    if(!deletende)
    {
        _label.textColor = [NSColor whiteColor];
        
        [[NSColor blackColor] set];
        NSBezierPath* roundRectPath = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(dirtyRect, deleteInset,deleteInset) xRadius:10 yRadius:10];
        //[roundRectPath addClip];
        [roundRectPath setLineWidth:2.0];
        [roundRectPath stroke];
    }
    else
    {
        _label.textColor = [NSColor redColor];
    }
    
    [[NSColor grayColor] set];
    if(self.node)
    {
        if(deletende)
        {
            [[NSColor clearColor] set];
        }
        else if(self.node.textProblem)
        {
            //[[NSColor redColor] set];
        }
        else
        {
            //Do nothing (gray)
        }
    }
    //NSBezierPath* roundRectPath3 = [NSBezierPath bezierPathWithRoundedRect:NSInsetRect(dirtyRect, lineWidth,lineWidth) xRadius:10 yRadius:10];
    //[roundRectPath3 addClip];
    NSRectFill(NSInsetRect(dirtyRect, 20.0,lineWidth));
}

@end
