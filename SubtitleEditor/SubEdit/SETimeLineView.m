//
//  SETimeLineView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SETimeLineView.h"
#import "SEAppDelegate.h"
#import "SEContentView.h"
#import "SEMoviewView.h"
#import "SENode.h"

@implementation SETimeLineView
{
    NSMutableArray*     _lineViews;
    NSMutableArray*     _subtitleBoxes;
    double              _lastCurrentTime;
    BOOL                _dragged;
    BOOL                _highlight;
    NSTextField*        _currentTimeLabel;
    CGFloat             _labelWidth;
    CGFloat             _labelHeight;
    CGFloat             _relativeBoxHeight;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
     
        self.allowedFileExtensions = [SETimeLineView allowedSubtitles];
        
        self.draggingCompletionBlock = ^(NSURL *url) {
          
            [[[SESingleton shared] appDelegate] insertSubtitle:url.path];
            
        };
        
        _currentTime = 0.0;
        
        self.wantsLayer = YES;
        self.layer.masksToBounds = YES;    
        
        _lineViews = [NSMutableArray new];
        _subtitleBoxes = [NSMutableArray new];
        _lastCurrentTime = 0.0;
        _currentTime = 0.0;
        
        [self setAutoresizesSubviews:YES];
        
        _labelWidth = 150.0;
        _labelHeight = 30.0;
        _currentTimeLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(self.frame.size.width / 2.0 - _labelWidth / 2.0, self.frame.size.height - _labelHeight, _labelWidth, _labelHeight)];
        [_currentTimeLabel setEditable:NO];
        [_currentTimeLabel setBordered:NO];
        _currentTimeLabel.alignment = NSTextAlignmentCenter;
        [_currentTimeLabel setFont:[NSFont fontWithName:@"Verdana-Bold" size:15.0]];
        [_currentTimeLabel setBackgroundColor:[NSColor clearColor]];
        [_currentTimeLabel setTextColor:[NSColor whiteColor]];
        [_currentTimeLabel setAutoresizingMask:NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin];
        [self addSubview:_currentTimeLabel];

        _relativeBoxHeight = 48.0;
    }
    
    return self;
}

+ (NSArray*)allowedSubtitles
{
    return [NSArray arrayWithObject:@"srt"];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)e 
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (void)viewDidMoveToWindow
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowResized:) name:NSWindowDidResizeNotification
                                               object:[self window]];
}

- (void)windowResized:(NSNotification *)notification;
{
    //recalculate visible boxes
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        SENode* node = box.node;
        if(box.node)
        {
            [box setFrame:[self makeNodeFrame:node]];
            [box update];
        }
    }
    
    [self update];
}

- (void)jumpToTime:(double)time
{
    self.currentTime = time;
    _lastCurrentTime = time;
    
    [self windowResized:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    NSBezierPath *topLine = [NSBezierPath bezierPath];
    [topLine moveToPoint:NSMakePoint(0.0, 0.0)];
    [topLine lineToPoint:NSMakePoint(self.bounds.size.width, 0.0)];
    [topLine setLineWidth:3.0];
    if([SESingleton shared].singleSelected)
    {
        [[NSColor blackColor] set]; /// Make future drawing the color of lineColor.
    }
    else
    {
        [[NSColor whiteColor] set]; /// Make future drawing the color of lineColor.
    }
    [topLine stroke];
    
    NSBezierPath *bottomLine = [NSBezierPath bezierPath];
    [bottomLine moveToPoint:NSMakePoint(0.0, dirtyRect.size.height)];
    [bottomLine lineToPoint:NSMakePoint(self.bounds.size.width, dirtyRect.size.height)];
    [bottomLine setLineWidth:3.0];
    if([SESingleton shared].singleSelected)
    {
        [[NSColor blackColor] set]; /// Make future drawing the color of lineColor.
    }
    else
    {
        [[NSColor whiteColor] set]; /// Make future drawing the color of lineColor.
    }
    [bottomLine stroke];
    
    CGFloat height = self.bounds.size.height - _labelHeight;
    NSBezierPath *line = [NSBezierPath bezierPath];
    [line moveToPoint:NSMakePoint(NSMidX([self bounds]), 0.0)];
    [line lineToPoint:NSMakePoint(NSMidX([self bounds]), self.bounds.size.height - _labelHeight)];
    [line moveToPoint:NSMakePoint(NSMidX([self bounds]) - _labelWidth / 2.0, height)];
    [line lineToPoint:NSMakePoint(NSMidX([self bounds]) + _labelWidth / 2.0, height)];
    [line lineToPoint:NSMakePoint(NSMidX([self bounds]) + _labelWidth / 2.0, height + _labelHeight - 4.0)];
    [line lineToPoint:NSMakePoint(NSMidX([self bounds]) - _labelWidth / 2.0, height + _labelHeight - 4.0)];
    [line lineToPoint:NSMakePoint(NSMidX([self bounds]) - _labelWidth / 2.0, height)];
    [line setLineWidth:3.0]; /// Make it easy to see
    [[NSColor blueColor] set]; /// Make future drawing the color of lineColor.
    [line stroke];
    
    
    NSBezierPath *subtitleLine = [NSBezierPath bezierPath];
    [subtitleLine moveToPoint:NSMakePoint(0.0, _relativeBoxHeight)];
    [subtitleLine lineToPoint:NSMakePoint(self.bounds.size.width, _relativeBoxHeight)];
    [subtitleLine moveToPoint:NSMakePoint(0.0, _relativeBoxHeight + BOX_HEIGHT)];
    [subtitleLine lineToPoint:NSMakePoint(self.bounds.size.width, _relativeBoxHeight + BOX_HEIGHT)];
    [subtitleLine setLineWidth:1.0];
    if([SESingleton shared].singleSelected)
    {
        [[NSColor blackColor] set]; /// Make future drawing the color of lineColor.
    }
    else
    {
        [[NSColor whiteColor] set]; /// Make future drawing the color of lineColor.
    }
    [subtitleLine stroke];
    
    
    if (self.highlighted)
    {
        [[NSColor greenColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: dirtyRect];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _lineViews = nil;
    _subtitleBoxes = nil;
}

- (void)reload
{
    for(SENode* node in [[SESingleton shared] content])
    {
        node.boxView = nil;
    }
    
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        [box removeFromSuperview];
    }
    
    [_subtitleBoxes removeAllObjects];
    
    self.currentTime = 0.0;
    _lastCurrentTime = 0.0;
    
    [self updateDisplay];
}

- (void)setCurrentTime:(double)currentTime
{
    _currentTime = currentTime;
    [self update];
    _lastCurrentTime = _currentTime;
    
    [_currentTimeLabel setStringValue:NSStringFromSETime(createTimeFromMilliSecond(_currentTime * 1000.0))];
    //SETime time = createTimeFromMilliSecond((long)_currentTime);
    //[_currentTimeLabel setStringValue:NSStringFromSETime(time)];
}

- (void)determineCurrentNode
{
    [[SESingleton shared] setCurrentNode:nil];
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        if(NSPointInRect(NSMakePoint(self.frame.size.width / 2.0, BOX_ORIGIN_Y), box.frame))
        {
            [[SESingleton shared] setCurrentNode:box.node];
            break;
        }
    }
}

- (void)update
{
    //first move all the boxes
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        CGFloat newX = box.frame.origin.x + (_lastCurrentTime - _currentTime) * 1000.0 / SPEED_SCALE;
        [box setFrameOrigin:NSMakePoint(newX, BOX_ORIGIN_Y)];
    }
    
    if([[SESingleton shared].content count] > 0)
    {
        //here must be a fast search code to show only visible nodes!!!!!!
        for(SENode* node in [[SESingleton shared] content])
        {
            if([self reuseSubtitleBoxByNode:node])
            {
                [node.boxView update];
            }
        }
    }
    
    //refresh textlabels
    [self determineCurrentNode];

    //detect duration conflict
    if([[SESingleton shared].checkOnFly state])
    {
        [self detectVisibleConflict];
    }
}

- (void)detectVisibleConflict
{
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        if(box.node)
        {
            box.node.error = 0;
        }
    }
    
    if([SESingleton shared].enableCheckError.state == NSOnState)
    {
        for(SESubtitleBoxView* box in _subtitleBoxes)
        {
            if(box.node)
            {
                SENode* right = nil;
                
                NSUInteger index = [[SESingleton shared].content indexOfObject:box.node];
                NSUInteger indexRight = index + 1;
                NSUInteger count = [[SESingleton shared].content count];
                
                if(indexRight < count)
                {
                    right = [[SESingleton shared].content objectAtIndex:indexRight];
                }
                [box.node conflictWithNode:right];
                
            }
        }
    }
    
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        [box updateError];
    }
}

- (void)mouseDown:(NSEvent *)theEvent
{
    _dragged = NO;
}

- (void)mouseDragged:(NSEvent *)theEvent 
{
    _dragged = YES;
    
    CGFloat e = self.currentTime - ((double)theEvent.deltaX / 1000.0 * (double)SPEED_SCALE);
    
    SEMoviewView* movieView = [SESingleton shared].movieView;
    
    float movieDuration = CMTimeGetSeconds(movieView.player.currentItem.asset.duration);
    
    if(e < 0.0)
    {
        self.currentTime = 0.0;
    }
    else if(e > movieDuration)
    {
        self.currentTime = movieDuration;
    }
    else
    {
        self.currentTime = e;
    }
    
    [[SESingleton shared].movieView seekToSeconds:e];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if([theEvent clickCount] == 1)
    {
        if(_dragged == NO)
        {
            if([[[SESingleton shared] movieView] isPlaying])
            {
                [[[[SESingleton shared] movieView] player] pause];
            }
            else
            {
                [[[[SESingleton shared] movieView] player] play];
            }
        }
    }
    else if([theEvent clickCount] == 2)
    {
        if(_dragged == NO)
        {
            //Double click
        }
    }
    
    if(![SESingleton shared].checkOnFly.state)
    {
        [[SESingleton shared] detectVisibleConflict];
    }
    
    _dragged = NO;
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    NSPoint click = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    CGFloat x = click.x;
    CGFloat y = click.y;
    
    if(y >= _relativeBoxHeight && y <= _relativeBoxHeight + BOX_HEIGHT && [theEvent clickCount] == 1)
    {
        double time = [self currentTime] - self.frame.size.width / 1000.0 / 2.0 * SPEED_SCALE + x / 1000.0 * SPEED_SCALE;
        double start = time - 0.3;
        double end = time + 0.3;
        
        if(start >= 0.0)
        {
            SENode* node = [SENode new];
            
            node.startTime = start;
            node.endTime = end;
            node.textProblem = YES;
            [[[SESingleton shared] content] insertObject:node atIndex:0];
            
            [SESingleton shared].currentNode = node;
            
            [[SESingleton shared] shortContentByTime];
            
            [self update];
        }
    }
    else if([theEvent clickCount] == 1 && [SESingleton shared].singleSelected)
    {
        [[SESingleton shared].contentView rightMouseUp:theEvent];
    }
    else if(y > _relativeBoxHeight + BOX_HEIGHT && [theEvent clickCount] == 2 && ![SESingleton shared].singleSelected)
    {
        [SESingleton shared].allSelected = ![SESingleton shared].allSelected;
        
        for(SENode* node in [SESingleton shared].content)
        {
            node.selected = [SESingleton shared].allSelected;
            if(node.boxView)
            {
                [node.boxView setNeedsDisplay:YES];
            }
        }
    }
    else
    {
        //Do nothing
    }
}

- (void)updateDisplay
{
    [self setNeedsDisplay:YES];
    for(SESubtitleBoxView* box in _subtitleBoxes)
    {
        [box setNeedsDisplay:YES];
    }
}

- (NSRect)makeNodeFrame:(SENode*)node
{
    NSRect retVal = NSMakeRect(0.0, 0.0, 100.0, BOX_HEIGHT);
    
    double start = node.startTime - (double)_currentTime;
    double end = node.endTime - node.startTime;
    
    start = start / SPEED_SCALE * 1.0;
    start *= 1000.0;
    start += self.frame.size.width / 2.0;
    end /= SPEED_SCALE;
    
    retVal = NSMakeRect(start, BOX_ORIGIN_Y, end * 1000.0, BOX_HEIGHT);
    
    return retVal;
    /*
    NSRect retVal = NSMakeRect(0.0, 0.0, 100.0, BOX_HEIGHT);
    
    double oStart = node.startTime * 1000.0;
    double oEnd = node.endTime* 1000.0 - node.startTime * 1000.0;
    
    double start = oStart - (double)_currentTime;
    double end = oEnd;
    
    start = start / SPEED_SCALE * 1.0;
    start += self.frame.size.width / 2.0;
    end /= SPEED_SCALE;
    
    retVal = NSMakeRect(start, BOX_ORIGIN_Y, end, BOX_HEIGHT);
    
    return retVal;*/
}

- (SESubtitleBoxView*)reuseSubtitleBoxByNode:(SENode*)node
{
    //search for invisible subtitleBoxViews.
    SESubtitleBoxView* retVal = nil;
    
    NSRect rect = [self makeNodeFrame:node];
    
    if(NSRectIntersection(self.frame, rect) == YES)
    {
        //node is on screen
        if(!node.boxView)
        {
            for(SESubtitleBoxView* box in _subtitleBoxes)
            {
                if([box isHidden])
                {
                    //found a box out of screen
                    retVal = box;
                    break;
                }
            }
            
            if(retVal == nil)
            {
                // Create
                SESubtitleBoxView* box = [[SESubtitleBoxView alloc] initWithFrame:rect];
                [_subtitleBoxes addObject:box];
                [[self superview] addSubview:box];
                retVal = box;
            }
            
            [retVal setFrame:rect];
            retVal.node = node;
            [retVal setHidden:NO];
            node.boxView = retVal;
            [retVal update];
        }
        else
        {
            [node.boxView setHidden:NO];
        }
    }
    else
    {
        // node is not on the screen
        if(node.boxView)
        {
            SESubtitleBoxView* bView = (SESubtitleBoxView*)node.boxView;
            if(![bView isHidden])
            {
                bView.node = nil;
                [bView updateError];
                [bView setHidden:YES];
                node.boxView = nil;
            }
        }
    }
    
    return retVal;
}

@end
