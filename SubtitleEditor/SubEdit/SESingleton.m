//
//  SESingleton.m
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SESingleton.h"
#import "SEStringEncoding.h"
#import "SETimeLineView.h"
#import "SEAppDelegate.h"
#import "SELoadSubtitleWindow.h"
#import "SEContentView.h"
#import "SEMoviewView.h"
#import "SETextView.h"
#import "SETextField.h"
#import "SENode.h"

static SESingleton* sharedInstance = nil;

@interface SESingleton (_private)

- (void)clickSelectedButton:(id)sender;

@end


@implementation SESingleton
{
    NSMenu*             _encodingMenu;
    NSButton*           _selectButton;
    NSTextField*        _volumeField;
    NSTextField*        _errorField;
}

+ (SESingleton*)shared
{
    if(sharedInstance == nil)
    {
        sharedInstance = [[SESingleton alloc] init];
    }
    return sharedInstance;
}

+ (NSString*)preproccessSubtitle:(NSString*)subtitle toArray:(NSMutableArray*)array
{
    return [SEStringEncoding preproccessSubtitle:subtitle toArray:array];
}

+ (NSString*)stringOfAllSubtitle
{
    NSMutableString* outString = [NSMutableString string];
    for(SENode* node in [SESingleton shared].content)
    {
        NSString* str = [NSString stringWithFormat:@"%ld\n%@",[[SESingleton shared].content indexOfObject:node] + 1,[node stringValue]];
        [outString appendString:str];
    }
    return outString;
}

- (id)init
{
    self = [super init];
    if(self != nil)
    {
        _content = [NSMutableArray new];
        _encodingArray = [SEStringEncoding encodingArray];
        self.subtitlePath = nil;
        _appDelegate = nil;
        _currentNode = nil;
        _allSelected = NO;
        _singleSelected = YES;
        
        [self loadViews];
    }
    return self;
}

- (void)setEncoding:(NSStringEncoding)encoding
{
    _encoding = encoding;
    if(_encodingButton != nil)
    {
        NSString* encodingValue = [NSString stringWithFormat:@"Encoding: %@",[NSString localizedNameOfStringEncoding:_encoding]];
        [_encodingButton setTitle:encodingValue];
    }
}
- (void)loadViews
{
    //contentView
    _contentView = [[SEContentView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 800.0, 800.0)];
    
    
    _editViewHeight = self.contentView.frame.size.height - 400.0;
    CGFloat width = self.contentView.frame.size.width;
    [self.contentView setAutoresizesSubviews:YES];
    [_editContentView setAutoresizingMask:NSViewHeightSizable | NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin |NSViewMaxYMargin |NSViewMinXMargin];
    //[_contentView setBackgroundColor:[NSColor redColor]];
    
    //moviewView
    _movieView = [[SEMoviewView alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, _editViewHeight)];
    [_movieView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    _movieView.autoresizesSubviews = YES;
    [self.contentView addSubview:_movieView];
    
    //editContentView
    _editContentView = [[SEView alloc] initWithFrame:NSMakeRect(0.0, _editViewHeight, width, self.contentView.frame.size.height - _editViewHeight)];
    [_editContentView setAutoresizingMask:NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin |NSViewMaxYMargin |NSViewMinXMargin];
    [_editContentView setAutoresizesSubviews:YES];
    //[_editContentView setBackgroundColor:[NSColor redColor]];
    [self.contentView addSubview:_editContentView];
    
    
    //_textView
    _textViewScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, 60.0)];
    [_textViewScroll setHasVerticalScroller:YES];
    [_textViewScroll setAutoresizingMask:NSViewWidthSizable];
    [_textViewScroll setBorderType:NSNoBorder];
    [_editContentView addSubview:_textViewScroll];
    
    _textView = [[SETextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, 60.0)];
    [_textView setVerticallyResizable:YES];
    _textView.delegate = self;
    _textView.font = [NSFont fontWithName:@"Verdana-Bold" size:18.0];
    //_textView.font = [NSFont fontWithName:@"Helvetica-Bold" size:18.0];
    _textView.textColor = [NSColor whiteColor];
    _textView.alignment = NSTextAlignmentCenter;
    [_textViewScroll setDocumentView:_textView];
    [_textView setAutoresizingMask:NSViewWidthSizable];
    [_textView setBackgroundColor:[NSColor darkGrayColor]];
    
    /*//slider
    _slider = [[NSSlider alloc] initWithFrame:NSMakeRect(0.0, 62.0, width, 20.0)];
    [_slider setTarget:self];
    [_slider setAction:@selector(sliderDidChange:)];
    [_slider setAutoresizingMask:NSViewWidthSizable];
    [_editContentView addSubview:_slider];
    //[_slider setDoubleValue:0.04];*/
    
    //timeLine
    _timeLineView = [[SETimeLineView alloc] initWithFrame:NSMakeRect(0.0, 60.0, width - 0.0, 190.0)];
    [_timeLineView setAutoresizesSubviews:YES];
    [_timeLineView setAutoresizingMask:NSViewWidthSizable];
    [_editContentView addSubview:_timeLineView];
    [_timeLineView setBackgroundColor:[NSColor lightGrayColor]];
    
    CGFloat timeWidth = 110.0;
    CGFloat labelWidth = 70.0;
    
    NSTextField* _startTimeLabelStatic = [[NSTextField alloc] initWithFrame:NSMakeRect(width - timeWidth - labelWidth - 10.0, _contentView.frame.size.height - 120.0, labelWidth, 22.0)];
    _startTimeLabelStatic.alignment = NSTextAlignmentLeft;
    _startTimeLabelStatic.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_startTimeLabelStatic setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin];
    [_startTimeLabelStatic setStringValue:@"Start:"];
    [_startTimeLabelStatic setBordered:NO];
    [_startTimeLabelStatic setBackgroundColor:[NSColor clearColor]];
    [_startTimeLabelStatic setTextColor:[NSColor whiteColor]];
    [_startTimeLabelStatic setEditable:NO];
    [_contentView addSubview:_startTimeLabelStatic];
    _startTimeLabel = [[SETextField alloc] initWithFrame:NSMakeRect(width - timeWidth - 5.0, _contentView.frame.size.height - 120.0, timeWidth, 22.0)];
    _startTimeLabel.delegate = self;
    _startTimeLabel.alignment = NSTextAlignmentLeft;
    _startTimeLabel.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_startTimeLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin];
    [_startTimeLabel setBordered:YES];
    [_startTimeLabel setBackgroundColor:[NSColor lightGrayColor]];
    [_startTimeLabel setTextColor:[NSColor whiteColor]];
    [_startTimeLabel setEditable:YES];
    [_contentView addSubview:_startTimeLabel];
    
    NSTextField* _endTimeLabelStatic = [[NSTextField alloc] initWithFrame:NSMakeRect(width - timeWidth - labelWidth - 10.0, _contentView.frame.size.height - 95.0, labelWidth, 22.0)];
    _endTimeLabelStatic.alignment = NSTextAlignmentLeft;
    _endTimeLabelStatic.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_endTimeLabelStatic setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin];
    [_endTimeLabelStatic setStringValue:@"End:"];
    [_endTimeLabelStatic setBordered:NO];
    [_endTimeLabelStatic setBackgroundColor:[NSColor clearColor]];
    [_endTimeLabelStatic setTextColor:[NSColor whiteColor]];
    [_endTimeLabelStatic setEditable:NO];
    [_contentView addSubview:_endTimeLabelStatic];
    _endTimeLabel = [[SETextField alloc] initWithFrame:NSMakeRect(width - timeWidth - 5.0, _contentView.frame.size.height - 95.0, timeWidth, 22.0)];
    _endTimeLabel.delegate = self;
    _endTimeLabel.alignment = NSTextAlignmentLeft;
    _endTimeLabel.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_endTimeLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin];
    [_endTimeLabel setBordered:YES];
    [_endTimeLabel setBackgroundColor:[NSColor lightGrayColor]];
    [_endTimeLabel setTextColor:[NSColor whiteColor]];
    [_endTimeLabel setEditable:YES];
    [_contentView addSubview:_endTimeLabel];
    
    NSTextField* _durationTimeLabelStatic = [[NSTextField alloc] initWithFrame:NSMakeRect(width - timeWidth - labelWidth - 10.0, _contentView.frame.size.height - 70.0, labelWidth, 22.0)];
    _durationTimeLabelStatic.alignment = NSTextAlignmentLeft;
    _durationTimeLabelStatic.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_durationTimeLabelStatic setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin];
    [_durationTimeLabelStatic setStringValue:@"Duration:"];
    [_durationTimeLabelStatic setBordered:NO];
    [_durationTimeLabelStatic setBackgroundColor:[NSColor clearColor]];
    [_durationTimeLabelStatic setTextColor:[NSColor whiteColor]];
    [_durationTimeLabelStatic setEditable:NO];
    [_contentView addSubview:_durationTimeLabelStatic];
    _durationLabel = [[SETextField alloc] initWithFrame:NSMakeRect(width - timeWidth - 5.0, _contentView.frame.size.height - 70.0, timeWidth, 22.0)];
    _durationLabel.delegate = self;
    _durationLabel.alignment = NSTextAlignmentLeft;
    _durationLabel.font = [NSFont fontWithName:@"Verdana-Bold" size:12.0];
    [_durationLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxXMargin|NSViewMinXMargin];
    [_durationLabel setBordered:YES];
    [_durationLabel setBackgroundColor:[NSColor lightGrayColor]];
    [_durationLabel setTextColor:[NSColor whiteColor]];
    [_durationLabel setEditable:YES];
    [_contentView addSubview:_durationLabel];
    
    _fileNameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(5.0, _contentView.frame.size.height - 20.0, width / 2.0 - 20, 20.0)];
    _fileNameLabel.alignment = NSTextAlignmentLeft;
    [_fileNameLabel setAutoresizingMask: NSViewMinYMargin|NSViewMaxXMargin|NSViewWidthSizable];
    [_fileNameLabel setStringValue:@"SubEdit"];
    [_fileNameLabel setBordered:NO];
    [_fileNameLabel setBackgroundColor:[NSColor clearColor]];
    [_fileNameLabel setEditable:NO];
    [_contentView addSubview:_fileNameLabel];
    
    _encodingButton = [[NSButton alloc] initWithFrame:NSMakeRect(width / 2.0, _contentView.frame.size.height - 20.0, width / 2.0 - 20, 20.0)];
    [_encodingButton setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin|NSViewWidthSizable];
    _encodingButton.alignment = NSTextAlignmentRight;
    [_encodingButton setBordered:NO];
    [_encodingButton setTarget:self];
    [_encodingButton setAction:@selector(chooseEncoding:)];
    [_contentView addSubview:_encodingButton];
    
    _encodingMenu = [[NSMenu alloc] initWithTitle:@"Encoding"];
    for(NSNumber* number in [SEStringEncoding encodingArray])
    {
        int encoding = [number intValue];
        NSMenuItem* item = [[NSMenuItem alloc] initWithTitle:[NSString localizedNameOfStringEncoding:encoding] action:@selector(chooseEncoding:) keyEquivalent:@""];
        item.tag = encoding;
        [_encodingMenu addItem:item];
    }
    
    _selectButton = [[NSButton alloc] initWithFrame:NSMakeRect(10.0, _contentView.frame.size.height - 120.0, 150.0, 20.0)];
    [_selectButton setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin|NSViewMaxXMargin];
    _selectButton.title = self.singleSelected ? @"Edit Selected Subtitle(s)" : @"Edit Single Subtitle";
    _selectButton.alignment = NSTextAlignmentCenter;
    [_selectButton setBordered:YES];
    [_selectButton setTarget:self];
    [_selectButton setAction:@selector(clickSelectedButton:)];
    [_contentView addSubview:_selectButton];
    
    _conflictButton = [[NSButton alloc] initWithFrame:NSMakeRect(10.0, _contentView.frame.size.height - 90.0, 150.0, 20.0)];
    [_conflictButton setAutoresizingMask: NSViewMinYMargin|NSViewMinXMargin|NSViewMaxXMargin];
    _conflictButton.title = @"Jump to next conflict";
    _conflictButton.alignment = NSTextAlignmentCenter;
    [_conflictButton setBordered:YES];
    [_conflictButton setTarget:self];
    [_conflictButton setAction:@selector(findConflict)];
    [_contentView addSubview:_conflictButton];
    
    // volume
    {
        _volume = [[NSSlider alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 350.0, 300.0, 150.0, 20.0)];
        [_volume setTarget:self];
        [_volume setAction:@selector(sliderDidChangeVolume:)];
        [_volume setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
        //[_editContentView addSubview:_volume];
        
        _volumeField = [[NSTextField alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 350.0, 280.0, 150.0, 20.0)];
        [_volumeField setEditable:NO];
        [_volumeField setBordered:NO];
        [_volumeField setBackgroundColor:[NSColor clearColor]];
        [_volumeField setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
        //[_editContentView addSubview:_volumeField];
        _volumeField.stringValue = [NSString stringWithFormat:@"Volume: %ld", (NSUInteger)(_volume.doubleValue * 1000.0)];
        
        NSImageView* volumeImage;
        volumeImage = [[NSImageView alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 383.0, _editContentView.frame.size.height - 105.0, BOX_HEIGHT, BOX_HEIGHT)];
        [volumeImage setImage:[NSImage imageNamed:@"volume"]];
        [volumeImage setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
        //[_editContentView addSubview:volumeImage];
        
    }
    
    _errorSlider = [[NSSlider alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 350.0, 340.0, 150.0, 20.0)];
    [_errorSlider setTarget:self];
    [_errorSlider setAction:@selector(sliderDidChangeErrorLevel:)];
    [_errorSlider setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
    [_editContentView addSubview:_errorSlider];
    
    _errorField = [[NSTextField alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 350.0, 320.0, 150.0, 20.0)];
    [_errorField setEditable:NO];
    [_errorField setBordered:NO];
    [_errorField setBackgroundColor:[NSColor clearColor]];
    [_errorField setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
    [_editContentView addSubview:_errorField];
    _errorField.stringValue = [NSString stringWithFormat:@"Min distance: %.2f sec", _errorSlider.doubleValue];
   
    _enableCheckError = [[NSButton alloc] initWithFrame:NSMakeRect(10.0, 340.0, 150.0, 20.0)];
    [_enableCheckError setTarget:self];
    [_enableCheckError setAction:@selector(enableCheckErrors)];
    [_enableCheckError setState:NSOnState];
    [_enableCheckError setButtonType:NSSwitchButton];
    [_enableCheckError setTitle:@"Check errors"];
    [_editContentView addSubview:_enableCheckError];
    
    _checkOnFly = [[NSButton alloc] initWithFrame:NSMakeRect(10.0, 360.0, 150.0, 20.0)];
    //[_checkOnFly setState:NSOffState];
    [_checkOnFly setButtonType:NSSwitchButton];
    [_checkOnFly setTitle:@"Check error on fly"];
    [_editContentView addSubview:_checkOnFly];
    [_checkOnFly setEnabled:YES];
    
    NSImageView*        _warning;
    NSImageView*        _warning2;
    NSImageView*        _error;
    CGFloat imageSize = 20.0;
    _warning = [[NSImageView alloc] initWithFrame:NSMakeRect(140 + imageSize, _editContentView.frame.size.height - 50.0, imageSize, imageSize)];
    [_warning setImage:[NSImage imageNamed:@"warning_pics"]];
    [_editContentView addSubview:_warning];
    
    _error = [[NSImageView alloc] initWithFrame:NSMakeRect(140, _editContentView.frame.size.height - 50.0, imageSize, imageSize)];
    [_error setImage:[NSImage imageNamed:@"error_pics"]];
    [_editContentView addSubview:_error];
    
    _warning2 = [[NSImageView alloc] initWithFrame:NSMakeRect(_editContentView.frame.size.width - 383.0, _editContentView.frame.size.height - 70.0, BOX_HEIGHT, BOX_HEIGHT)];
    [_warning2 setImage:[NSImage imageNamed:@"warning_pics"]];
    [_warning2 setAutoresizingMask:NSViewMinYMargin|NSViewMinXMargin];
    [_editContentView addSubview:_warning2];
    
    self.encoding = NSWindowsCP1250StringEncoding;
    
    [_timeLineView.currentTimeLabel setStringValue:NSStringFromSETime(createTimeFromMilliSecond(0.0))];
}

- (void)enableCheckErrors
{
    [_checkOnFly setEnabled:[_enableCheckError state]];
    [self detectVisibleConflict];
}

- (void)reloadData
{
    //empty all field
    
    //reload timeLine tooo
    [_timeLineView reload];
    
    self.currentNode = nil;
    
    [[_textView window] makeFirstResponder:_textView];
}

- (void)jumpToTime:(double)seconds
{
    [_timeLineView jumpToTime:seconds];
}

- (void)setTimeDetailWithNode:(SENode*)node
{
    if(node)
    {
        [_startTimeLabel setStringValue:NSStringFromSETime(createTimeFromMilliSecond(node.startTime * 1000.0))];
        [_endTimeLabel setStringValue:NSStringFromSETime(createTimeFromMilliSecond(node.endTime * 1000.0))];
        [_durationLabel setStringValue:NSStringFromSETime(createTimeFromMilliSecond(node.endTime * 1000.0 - node.startTime * 1000.0))];
    }
}

- (void)setCurrentNode:(SENode*)node
{
    _currentNode = node;
    if(node)
    {
        if(node.text)
        {
            [_textView setString:node.text];
        }
        
        [self setTimeDetailWithNode:node];
        
        [self.fileNameLabel setStringValue:[NSString stringWithFormat:@"Current subtitle: %ld totally: %ld", [self.content indexOfObject:node] + 1, self.content.count]];
        
        [[_textView window] makeFirstResponder:_textView];
    }
    else
    {
        [_textView setString:@""];
        [_startTimeLabel setStringValue:@""];
        [_endTimeLabel setStringValue:@""];
        [_durationLabel setStringValue:@""];
        
        [self.fileNameLabel setStringValue:[NSString stringWithFormat:@"%ld subtitles", self.content.count]];
    }
    
}

- (void)setSubtitlePath:(NSString *)subtitlePath
{
    _subtitlePath = subtitlePath;
    
    self.mainWindow.title = [NSString stringWithFormat:@"%@",subtitlePath ? subtitlePath : @""];
}

- (void)sliderDidChangeVolume:(NSSlider*)slider
{
    [_movieView setVolume:(CGFloat)slider.doubleValue * 1.0];
    _volumeField.stringValue = [NSString stringWithFormat:@"Volume: %ld", (NSUInteger)(slider.doubleValue * 100.0)];
}

- (void)sliderDidChangeErrorLevel:(NSSlider*)slider
{
    _errorField.stringValue = [NSString stringWithFormat:@"Min distance: %.2f sec", slider.doubleValue];
    
    [self detectVisibleConflict];
}

- (void)setMovieVolume:(CGFloat)volume
{
    [_movieView.player setVolume:(CGFloat)volume * 1.0];
    _volumeField.stringValue = [NSString stringWithFormat:@"Volume: %ld", (NSUInteger)(volume * 100.0)];
}

- (void)textFieldKeyDown:(SETextField*)textField
{
    
}

- (void)textViewShouldChangeText:(SETextView*)textView
{
}

- (void)textViewDidChangeText:(SETextView*)textView
{
    [[_movieView player] pause];
    
    _textView.font = [NSFont fontWithName:@"Verdana-Bold" size:18.0];
    _textView.textColor = [NSColor whiteColor];
    _textView.alignment = NSTextAlignmentCenter;
    
    if(_currentNode)
    {
        if([textView string])
        {
            NSString *subString = [[[textView string] componentsSeparatedByString:@"\n"] lastObject];
            if(![subString isEqualToString:@""] || [textView.string isEqualToString:@""])
            {
                _currentNode.text = [NSString stringWithFormat:@"%@",textView.string];
                
                if(_currentNode.boxView)
                {
                    [_currentNode.boxView update];
                }
                
                if([textView.string isEqualToString:@""])
                {
                    _currentNode.textProblem = YES;
                }
                else
                {
                    _currentNode.textProblem = NO;
                }
            }
            
            //check the string
            NSArray* a = [_currentNode.text componentsSeparatedByString:@"\n"];
            for(NSString* s in a)
            {
                if([s isEqualToString:@""])
                {
                    _currentNode.textProblem = YES;
                    break;
                }
            }
        }
    }
    else
    {
        //create a node
        SENode* node = [[SENode alloc] init];
        double start = (double)[_timeLineView currentTime];
        double end = start + 0.5;
        
        node.startTime = start;
        node.endTime = end;
        
        [[self content] insertObject:node atIndex:0];

        if(![textView.string isEqualToString:@"\n"])
        {
            node.text = [NSString stringWithFormat:@"%@",textView.string];
        }
        
        [self shortContentByTime];
        
        self.currentNode = node;
        
        [_timeLineView update];
    }
}

- (void)textViewKeyDown:(SETextView*)textView
{
    
}

- (void)chooseEncoding:(id)sender
{
    if([sender isKindOfClass:[NSButton class]])
    {
        //NSRect frame = [(NSButton *)sender frame];
        //NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y - 300.0)toView:nil];
        
        NSEvent *event =  [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                                             location:NSMakePoint(_contentView.frame.size.width - 300.0, 350.0)
                                        modifierFlags:0 // 0x100
                                            timestamp:0.0
                                         windowNumber:[[(NSButton *)sender window] windowNumber]
                                              context:[[(NSButton *)sender window] graphicsContext]
                                          eventNumber:0
                                           clickCount:1
                                             pressure:1];
        
        [NSMenu popUpContextMenu:_encodingMenu withEvent:event forView:_contentView];
    }
    else if([sender isKindOfClass:[NSMenuItem class]])
    {
        NSMenuItem* item = (NSMenuItem*)sender;
        [self setEncoding:item.tag];
    }
    else
    {
        //Do ntohing
    }
}

- (void)clickSelectedButton:(id)sender
{
    self.singleSelected = !self.singleSelected;
    _selectButton.title = self.singleSelected ? @"Edit Selected Subtitle(s)" : @"Edit Single Subtitle";
    if(self.singleSelected)
    {
        [_timeLineView setBackgroundColor:[NSColor lightGrayColor]];
    }
    else
    {
        [_timeLineView setBackgroundColor:[NSColor blackColor]];
    }
    [_timeLineView updateDisplay];
}

- (void)shortContentByTime
{
    [self.content sortUsingComparator:^NSComparisonResult(SENode*  _Nonnull obj1, SENode*  _Nonnull obj2) {
        
        NSComparisonResult retVal = NSOrderedSame;
        
        if(obj1.startTime < obj2.startTime)
        {
            retVal = NSOrderedAscending;
        }
        else if(obj1.startTime > obj2.startTime)
        {
            retVal = NSOrderedDescending;
        }
        else
        {
            //Do nothing
        }
        return retVal;
        
    }];
}

- (void)detectVisibleConflict
{
    [_timeLineView detectVisibleConflict];
}

- (SENode*)findConflict
{
    SENode* retVal = nil;
    
    NSUInteger index = 0;
    
    if(self.currentNode != nil)
    {
        index = [[self content] indexOfObject:self.currentNode] + 1;
    }
    
    if(self.content.count > 1)
    {
        for(NSUInteger i = index + 1 ; i < [self content].count ; i++)
        {
            SENode* node1 = [self.content objectAtIndex:i - 1];
            SENode* node2 = [self.content objectAtIndex:i];
            if([node1 conflictWithNode:node2] > 0 || node1.textProblem)
            {
                retVal = node1;
                
                break;
            }
        }
        
        if(retVal)
        {
            double currTime = retVal.endTime - 0.03;
            [_timeLineView setCurrentTime:currTime];
            [self setCurrentNode:retVal];
            
            [[SESingleton shared].movieView seekToSeconds:currTime];
        }
    }
    return retVal;
}

- (void)windowDidResize:(NSNotification *)notification
{
    //if(self.movieView.movie)
    {
        //NSSize size = [(NSValue*)[self.movieView.movie attributeForKey:QTMovieNaturalSizeAttribute] sizeValue];
        //NSRect movieSize = [[self movieView] movieBounds];
        //NSLog(@"original:%@  act:%@",NSStringFromSize(size), NSStringFromRect(movieSize));
    }
}

- (void)windowWillClose:(NSNotification *)notification;
{
    [[NSApplication sharedApplication] terminate:nil];
}

@end
