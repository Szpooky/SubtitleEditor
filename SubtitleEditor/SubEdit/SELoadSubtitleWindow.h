//
//  SELoadSubtitleWindow.h
//  SubEdit
//
//  Created by Peter Sipos on 10/30/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <AppKit/AppKit.h>

typedef void (^_block)(NSString* path, NSString* subtitle);

@interface SELoadSubtitleWindow : NSWindow <NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate>
{
    NSData*         _data;
    NSButton*       _okButton;
    NSButton*       _cancelButton;
    NSTextView*     _textView;
    NSScrollView*   _textViewScroll;
    NSTableView*    _tableView;
    NSTextField*    _fileNameLabel;
    BOOL            _isSave;
}
@property (nonatomic, copy)     _block               block;
@property (nonatomic, strong)   NSString*            path;


+ (SELoadSubtitleWindow*)createWithFilePath:(NSString*)path finishBlock:(_block)block;
+ (SELoadSubtitleWindow*)createTextViewer;
+ (SELoadSubtitleWindow*)createSaveWithPath:(NSString*)path;

@end
