//
//  SELoadSubtitleWindow.m
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SELoadSubtitleWindow.h"
#import "SEStringEncoding.h"
#import "SEView.h"

@interface SELoadSubtitleWindow ( _private )
- (void)setSaveWindow:(BOOL)save;
- (void)showSubtitle;
- (void)okAction;
- (void)cancelAction;
- (void)selectTableViewRowByEncoding:(NSStringEncoding)encoding;
@end



@implementation SELoadSubtitleWindow

+ (SELoadSubtitleWindow*)createWithFilePath:(NSString*)path finishBlock:(_block)block
{
    SELoadSubtitleWindow* m = [[SELoadSubtitleWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 700.0, 600.0) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskTexturedBackground backing:NSBackingStoreBuffered defer:YES];
    m.block = block;
    m.path = path;
    
    [[SESingleton shared].mainWindow beginSheet:m completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    return m;
}

+ (SELoadSubtitleWindow*)createSaveWithPath:(NSString*)path
{
    SELoadSubtitleWindow* m = [[SELoadSubtitleWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 700.0, 600.0) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskTexturedBackground backing:NSBackingStoreBuffered defer:YES];
    [m setSaveWindow:YES];
    m.block = nil;
    m.path = path;
    
    [[SESingleton shared].mainWindow beginSheet:m completionHandler:^(NSModalResponse returnCode) {
        
    }];

    return m;
}


+ (SELoadSubtitleWindow*)createTextViewer
{
    SELoadSubtitleWindow* m = [[SELoadSubtitleWindow alloc] initWithContentRect:NSMakeRect(0.0, 0.0, 700.0, 600.0) styleMask:NSWindowStyleMaskTitled|NSWindowStyleMaskTexturedBackground backing:NSBackingStoreBuffered defer:YES];
    m.block = nil;
    m.path = nil;
    
    [m showSubtitle];
    
    [[SESingleton shared].mainWindow beginSheet:m completionHandler:^(NSModalResponse returnCode) {
        
    }];
    
    return m;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    
    if(self != nil)
    {
        [self becomeKeyWindow];
        [self becomeFirstResponder];
        
        [self setTitle:@"Load Subtitle"];
        
        _isSave = NO;
        
        SEView* wContentView = [[SEView alloc] initWithFrame:contentRect];
        [self setContentView:wContentView];
        
        CGFloat width = contentRect.size.width / 2.0 + 100.0;
        CGFloat height = contentRect.size.height - 30.0;
        
        _textViewScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(5.0, 3.0, width, height)];
        [_textViewScroll setHasVerticalScroller:YES];
        [_textViewScroll setHasHorizontalScroller:YES];
        [_textViewScroll setBorderType:NSNoBorder];
        [wContentView addSubview:_textViewScroll];

        _textView = [[NSTextView alloc] initWithFrame:NSMakeRect(0.0, 0.0, width, height)];
        [_textView setHorizontallyResizable:YES];
        [_textView setVerticallyResizable:YES];
        [_textView setEditable:YES];
        _textView.delegate = self;
        _textView.font = [NSFont fontWithName:@"Verdana-Bold" size:14.0];
        //_textView.font = [NSFont fontWithName:@"Helvetica-Bold" size:18.0];
        _textView.textColor = [NSColor whiteColor];
        _textView.alignment = NSTextAlignmentLeft;
        [_textViewScroll setDocumentView:_textView];
        [_textView setAutoresizingMask:NSViewWidthSizable];
        [_textView setBackgroundColor:[NSColor darkGrayColor]];
        
        _tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(width + 20.0, 6.0, 220.0, height)];
        [_tableView setBackgroundColor:[NSColor clearColor]];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setGridColor:[NSColor greenColor]];
        [_tableView setRowHeight:25.0];
        [wContentView addSubview:_tableView];
        [_tableView reloadData];
        //add 1 column
        NSTableColumn* c = [[NSTableColumn alloc] initWithIdentifier:@"id0"];
        [c setWidth:220.0];
        [c setResizingMask:NSTableColumnNoResizing];
        [_tableView addTableColumn:c];
        
        _cancelButton = [[NSButton alloc] initWithFrame:NSMakeRect(width + 130.0, height - 40.0, 100.0, 50.0)];
        [_cancelButton setBezelStyle:NSRoundedBezelStyle];
        [_cancelButton setTitle:@"Cancel"];
        [wContentView addSubview:_cancelButton];
        _cancelButton.target = self;
        _cancelButton.action = @selector(cancelAction);
        
        _okButton = [[NSButton alloc] initWithFrame:NSMakeRect(width + 30.0, height - 40.0, 100.0, 50.0)];
        [_okButton setBezelStyle:NSRoundedBezelStyle];
        [_okButton setTitle:@"Ok"];
        [wContentView addSubview:_okButton];
        _okButton.target = self;
        _okButton.action = @selector(okAction);
        
        _fileNameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(5.0, wContentView.frame.size.height - 20.0, wContentView.frame.size.width, 20.0)];
        [_fileNameLabel setBordered:NO];
        [_fileNameLabel setBackgroundColor:[NSColor clearColor]];
        [_fileNameLabel setEditable:NO];
        [wContentView addSubview:_fileNameLabel];
    }
    return self;
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if(!self.path)
    {
        [[SESingleton shared].mainWindow endSheet:self returnCode:NSModalResponseStop];
    }
}

- (void)setPath:(NSString *)path
{
    _path = path;
    
    if(!_isSave)
    {
        if(path)
        {
            _data = [NSData dataWithContentsOfFile:_path];
            
            [_fileNameLabel setStringValue:_path];
            
            [self selectTableViewRowByEncoding:[SESingleton shared].encoding];
            [self showSubtitle];
        }
    }
    else
    {
        if(path)
        {
            [_fileNameLabel setStringValue:_path];
            
            //[_textView setString:[SESingleton stringOfAllSubtitle]];
            
            [_okButton setTitle:@"Save"];
            [self selectTableViewRowByEncoding:[SESingleton shared].encoding];
            [self showSubtitle];

        }
        
    }
}

- (void)selectTableViewRowByEncoding:(NSStringEncoding)encoding
{
    NSUInteger index = [SEStringEncoding indexOfEncoding:encoding inArray:[SESingleton shared].encodingArray];
    [_tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:YES];
}

- (void)okAction
{
    if(_isSave)
    {
        NSError* outError = nil;
        [[_textView string] writeToFile:_path atomically:YES encoding:[SESingleton shared].encoding error:&outError];
        
        if(outError)
        {
            [[NSAlert alertWithError:outError] runModal];
        }
        else
        {
            [SESingleton shared].mainWindow.title = [NSString stringWithFormat:@"%@",_path];
            [SESingleton shared].subtitlePath = [NSString stringWithFormat:@"%@",_path];
        }

    }
    else
    {
        if(self.block)
        {
            self.block(self.path, [_textView string]);
        }
    }
    
    [[SESingleton shared].mainWindow endSheet:self returnCode:NSModalResponseStop];
}

- (void)cancelAction
{
    [[SESingleton shared].mainWindow endSheet:self returnCode:NSModalResponseStop];
}

- (void)showSubtitle
{
    if(self.path && !_isSave)
    {
        NSString* subtitleString = [[NSString alloc] initWithData:_data encoding:[SESingleton shared].encoding];
        if(subtitleString != nil)
        {
            [_textView setString:subtitleString];
        }
        else
        {
            [_textView setString:@""];
        }
    }
    else
    {
        if(!_isSave)
        {
            [_okButton setHidden:YES];
            [_tableView setHidden:YES];
            [_textViewScroll setFrameSize:NSMakeSize(self.frame.size.width - 40.0 - _okButton.frame.size.width, _textView.frame.size.height)];
        }
        
        [_textView setString:[SESingleton stringOfAllSubtitle]];
    }
    
    [_textView sizeToFit];
    
    [_tableView reloadData];
}

- (void)setSaveWindow:(BOOL)save
{
    _isSave = save;
    
    if(save)
    {
        self.title = @"Save Subtitle As";
    }
    else
    {
        self.title = @"Load Subtitle";
    }
}

//tableView datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[SESingleton shared] encodingArray].count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id key = [[[SESingleton shared] encodingArray] objectAtIndex:row];
    
    NSString* value = [NSString localizedNameOfStringEncoding:[key intValue]];

    return value;
}

- (NSIndexSet *)tableView:(NSTableView *)tableView selectionIndexesForProposedSelection:(NSIndexSet *)proposedSelectionIndexes
{
    NSString* key = [[[SESingleton shared] encodingArray] objectAtIndex:[proposedSelectionIndexes firstIndex]];
    
    [[SESingleton shared] setEncoding:[key intValue]];
    
    [self showSubtitle];
    
    return proposedSelectionIndexes;
}

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return NO;
}

- (void)dealloc
{
    self.block = nil;
    self.path = nil;
    _data = nil;
}

@end
