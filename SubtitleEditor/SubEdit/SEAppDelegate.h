//
//  SEAppDelegate.h
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define MENU_RECENT_ITEM_KEY @"subEditRecent001"

@interface SEWindow : NSWindow

@end


@interface SEAppDelegate : NSObject <NSApplicationDelegate>

@property (assign)      IBOutlet    SEWindow            *window;
@property (assign)      IBOutlet    NSMenu              *menu;

- (IBAction)newSubtitle:(id)sender;
- (IBAction)openVideo:(id)sender;
- (IBAction)insertASubtitle:(id)sender;
- (IBAction)openSubtitleFromTxt:(id)sender;
- (IBAction)saveSubtitle:(id)sender;
- (IBAction)saveSubtitleAs:(id)sender;
- (IBAction)closeSubtitle:(id)sender;
- (IBAction)closeVideo:(id)sender;

- (IBAction)undo:(id)sender;

- (NSError*)loadMovie:(id)sender;                   //sender: UIButton or NSString
- (void)loadSubtitle:(id)sender;                    //sender: UIButton or NSString
- (void)insertSubtitle:(id)sender;

- (void)reloadRecentItem;

@end

