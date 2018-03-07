//
//  SEMoviewView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEMoviewView.h"
#import "SESingleton.h"
#import "SETimeLineView.h"
#import "SEAppDelegate.h"


@interface SEMoviewView ()

@property (nonatomic, strong)   id      observer;

@property (nonatomic, assign)   BOOL    needRefresh;

@end

@implementation SEMoviewView
{
    BOOL _highlighted;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self registerForDraggedTypes:@[NSPasteboardTypeFileURL]];
        
        //self.controlsStyle = AVPlayerViewControlsStyleNone;
    }
    return self;
}

- (void)setVolume:(CGFloat)volume
{
    [self.player setVolume:volume];
}

- (CGFloat)volume
{
    return self.player.volume;
}

- (BOOL)isPlaying
{
    return ([self player] != nil) && ([self.player rate] != 0);
}

- (BOOL)loadMovieWithURL:(NSURL*)url
{
    BOOL retVal = YES;
    
    [self closeMovie];
    
    self.player = [AVPlayer playerWithURL:url];
    
    __weak typeof(self) weakSelf = self;
    
    self.observer = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 60) queue:NULL usingBlock:^(CMTime time) {
        
        if(weakSelf.needRefresh)
        {
            [[[SESingleton shared] timeLineView] setCurrentTime:CMTimeGetSeconds(time)];
        }
        else
        {
            weakSelf.needRefresh = YES;
        }
    }];
    
    return retVal;
}

- (void)closeMovie
{
    [self.player pause];
    
    [self.player removeTimeObserver:self.observer];
    
    self.player = nil;
}

- (void)seekToSeconds:(double)seconds
{
    _needRefresh = NO;
    
    [self.player pause];
    
    [self.player seekToTime:CMTimeMakeWithSeconds(seconds, 1000) completionHandler:^(BOOL finished) {
        
        if(finished)
        {
            //[self.player play];
        }
    }];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)e
{
    return YES;
}

- (BOOL)mouseDownCanMoveWindow
{
    return NO;
}

- (void)mouseDown:(NSEvent *)theEvent;
{
    if([self player] != nil)
    {
        self.needRefresh = YES;
        [[SESingleton shared].timeLineView mouseDown:theEvent];
    }
    else
    {
        if([theEvent clickCount] == 2)
        {
            [[SESingleton shared].appDelegate openVideo:nil];
        }
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [[SESingleton shared].timeLineView mouseDragged:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [[SESingleton shared].timeLineView mouseUp:theEvent];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    //Do nothing yet
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    //Do nothing
}

- (void)otherMouseDown:(NSEvent *)theEvent
{
    //Do nothing
}

#pragma mark - Destination Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    //if ([sender draggingSourceOperationMask] & NSDragOperationCopy )
    {
        _highlighted = YES;
        
        [self setNeedsDisplay:YES];

        return NSDragOperationCopy;
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlighted = NO;
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    if(_highlighted)
    {
        [[NSColor greenColor] set];
        [NSBezierPath setDefaultLineWidth: 5];
        [NSBezierPath strokeRect: rect];
    }
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    _highlighted = NO;
    [self setNeedsDisplay: YES];
    
    NSURL* fileURL = [NSURL URLFromPasteboard:[sender draggingPasteboard]];
    return fileURL != nil;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    if ( [sender draggingSource] != self )
    {
        NSURL* fileURL = [NSURL URLFromPasteboard: [sender draggingPasteboard]];
        [[[SESingleton shared] appDelegate] loadMovie:[fileURL path]];
    }
    return YES;
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    
    [self.player removeTimeObserver:self.observer];
}

@end
