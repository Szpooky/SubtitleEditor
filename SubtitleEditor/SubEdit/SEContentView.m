//
//  SEContentView.m
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEContentView.h"
#import "SESingleton.h"
#import "SEMoviewView.h"
#import "SEAppDelegate.h"
#import "SELoadSubtitleWindow.h"

@implementation SEContentView

- (void)mouseUp:(NSEvent *)theEvent
{
    if([theEvent clickCount] == 2)
    {
        [[SESingleton shared].movieView.player pause];
        
        if([SESingleton shared].subtitlePath == nil && [[SESingleton shared].content count] ==0)
        {
            [[SESingleton shared].appDelegate insertASubtitle:nil];
        }
        else
        {
            [SELoadSubtitleWindow createTextViewer];
        }
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    NSMenuItem* fileMenu = [[SESingleton shared].appDelegate.menu itemWithTitle:@"File"];
    
    NSMenu* menu = [[fileMenu submenu] copy];
    
    NSMenuItem* undoItem = [[[[[SESingleton shared].appDelegate.menu itemWithTitle:@"Edit"] submenu] itemWithTitle:@"Undo"] copy];
    [menu insertItem:undoItem atIndex:0];
    [menu insertItem:[NSMenuItem separatorItem] atIndex:1];
    
    [NSMenu popUpContextMenu:menu withEvent:theEvent forView:self];
}

@end
