//
//  SESingleton.h
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEUtils.h"

@class SEView;
@class SETimeLineView;
@class SEAppDelegate;
@class SEContentView;
@class SEMoviewView;
@class SETextView;
@class SETextField;
@class SENode;

@interface SESingleton : NSObject <NSWindowDelegate, NSTextViewDelegate, NSTextFieldDelegate>

@property (nonatomic, readonly)     SEContentView*      contentView;
@property (nonatomic, readonly)     SEView*             editContentView;
@property (nonatomic, readonly)     SEMoviewView*       movieView;
@property (nonatomic, readonly)     SETextView*         textView;
@property (nonatomic, readonly)     NSScrollView*       textViewScroll;
@property (nonatomic, readonly)     SETimeLineView*     timeLineView;
@property (nonatomic, readonly)     CGFloat             editViewHeight;
@property (nonatomic, readonly)     NSMutableArray*     content;
@property (nonatomic, assign)       NSStringEncoding    encoding;
@property (nonatomic, readonly)     NSButton*           encodingButton;
@property (nonatomic, readonly)     NSMutableArray*     encodingArray;
@property (nonatomic, weak)         NSWindow*           mainWindow;
@property (nonatomic, weak)         SENode*             currentNode;
@property (nonatomic, strong)       NSString*           subtitlePath;
@property (nonatomic, readonly)     NSTextField*        fileNameLabel;
@property (nonatomic, weak)         SEAppDelegate*      appDelegate;
@property (nonatomic, readonly)     SETextField*        startTimeLabel;
@property (nonatomic, readonly)     SETextField*        endTimeLabel;
@property (nonatomic, readonly)     SETextField*        durationLabel;
@property (nonatomic)               BOOL                allSelected;
@property (nonatomic)               BOOL                singleSelected;
@property (nonatomic, readonly)     NSButton*           conflictButton;
@property (nonatomic, readonly)     NSSlider*           volume;
@property (nonatomic, readonly)     NSSlider*           errorSlider;
@property (nonatomic, readonly)     NSButton*           enableCheckError;
@property (nonatomic, readonly)     NSButton*           checkOnFly;

+ (SESingleton*)shared;

//PreProcessing the readed subtitle. Return errorString, if error occured, otherwise  return nil (SUCCESS).
+ (NSString*)preproccessSubtitle:(NSString*)subtitle toArray:(NSMutableArray*)array;
+ (NSString*)stringOfAllSubtitle;

- (void)loadViews;
- (void)reloadData;
- (void)jumpToTime:(double)seconds;
- (void)shortContentByTime;
- (void)chooseEncoding:(id)sender;
- (void)detectVisibleConflict;
- (SENode*)findConflict; //slow method
- (void)setMovieVolume:(CGFloat)volume;
- (void)setTimeDetailWithNode:(SENode*)node;

// Delegates
- (void)textFieldKeyDown:(SETextField*)textField;
- (void)textViewShouldChangeText:(SETextView*)textView;
- (void)textViewDidChangeText:(SETextView*)textView;
- (void)textViewKeyDown:(SETextView*)textView;

@end
