//
//  SEAppDelegate.m
//  SubEdit
//
//  Created by Peter Sipos on 10/29/12.
//  Copyright (c) 2012 PeterSipos. All rights reserved.
//

#import "SEAppDelegate.h"
#import "SELoadSubtitleWindow.h"
#import "SETimeLineView.h"
#import <AVFoundation/AVFoundation.h>
#import "SEMoviewView.h"
#import "SEContentView.h"
#import "SEUtils.h"
#import "SENode.h"

@implementation SEWindow
- (NSSize)minSize
{
    return NSMakeSize(800, 600);
}
@end


@implementation SEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    self.window.delegate = [SESingleton shared];
    [self.window setContentView:[[SESingleton shared] contentView]];
    [SESingleton shared].mainWindow = self.window;
    [SESingleton shared].appDelegate = self;
    
    [self reloadRecentItem];
}

- (void)clearRecentItems
{
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:MENU_RECENT_ITEM_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reloadRecentItem];
}

- (void)reloadRecentItem
{
    NSMutableArray* array = [[NSUserDefaults standardUserDefaults] objectForKey:MENU_RECENT_ITEM_KEY];
    
    NSMenuItem* fileMenu = [self.menu itemWithTitle:@"File"];
    
    NSMenu* recentSubMenu = [[NSMenu alloc] initWithTitle:@"Open Recent"];
    
    for(NSMutableDictionary* dictionary in array)
    {
        NSString* name = [dictionary objectForKey:@"name"];
        NSString* selName = [dictionary objectForKey:@"sel"];
        SEL selector = NSSelectorFromString(selName);
        
        NSMenuItem* item = [recentSubMenu addItemWithTitle:name action:selector keyEquivalent:@"?"];
        [item setTarget:self];
    }
    
    if([array count])
    {
        [recentSubMenu addItem:[NSMenuItem separatorItem]];
        NSMenuItem* clearMenuItem = [recentSubMenu addItemWithTitle:@"Clear" action:@selector(clearRecentItems) keyEquivalent:@"?"];
        [clearMenuItem setTarget:self];
    }
    
    [[[fileMenu submenu] itemWithTitle:@"Open Recent"] setSubmenu:recentSubMenu];

}

- (void)addToRecent:(NSString*)recentItem withSelector:(SEL)selector
{
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:recentItem forKey:@"name"];
    [dictionary setObject:NSStringFromSelector(selector) forKey:@"sel"];
    
    NSMutableArray* array = [[[NSUserDefaults standardUserDefaults] objectForKey:MENU_RECENT_ITEM_KEY] mutableCopy];
    if(array == nil)
    {
        array = [NSMutableArray arrayWithObject:dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:MENU_RECENT_ITEM_KEY];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else
    {
        id contentToRemove = nil;
        for(NSMutableDictionary* dictionary in array)
        {
            NSString* name = [dictionary objectForKey:@"name"];
            
            if([name isEqualToString:recentItem])
            {
                contentToRemove = dictionary;
                break;
            }
        }
        
        if(contentToRemove)
        {
            [array removeObject:contentToRemove];
        }
        
        [array insertObject:dictionary atIndex:0];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self reloadRecentItem];
}

- (NSError*)loadMovie:(id)sender
{
    NSString *movieString = (NSString*)sender;
    
    if([sender isKindOfClass:[NSMenuItem class]])
    {
        movieString = [(NSMenuItem*)sender title];
    }
    
    [[SESingleton shared] setMovieVolume:0.0];
    
    NSError* outError = nil;

    if([[[SESingleton shared] movieView] loadMovieWithURL:[NSURL fileURLWithPath:movieString]])
    {
        AVPlayer* player = [[[SESingleton shared] movieView] player];
        
        [self addToRecent:movieString withSelector:@selector(loadMovie:)];
        [[SESingleton shared] setMovieVolume:player.volume];
    }
    else
    {
        outError = [NSError errorWithDomain:@"Error" code:0 userInfo:@{NSLocalizedDescriptionKey : @"Can not open movie"}];
        [[NSAlert alertWithError:outError] runModal];
    }

    [[SESingleton shared] reloadData];
    
    return outError;
}

- (IBAction)openVideo:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    //NSArray *types = [[NSArray alloc] initWithArray:[QTMovie movieUnfilteredFileTypes]];
    [openDlg setAllowedFileTypes:[AVURLAsset audiovisualTypes]];
	//[openDlg setAllowsOtherFileTypes:YES];
	
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:YES];
	
	// Enable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:NO];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ([openDlg runModal] == NSModalResponseOK)
	{
		NSString *file = [[openDlg URL] path];
     
        if([self loadMovie:file] == nil)
        {
            //done
        }
    }
}

- (void)loadSubtitle:(id)sender
{
    NSString *subtitleString = (NSString*)sender;
    
    if([sender isKindOfClass:[NSMenuItem class]])
    {
        subtitleString = [(NSMenuItem*)sender title];
    }

    [SELoadSubtitleWindow createWithFilePath:subtitleString finishBlock:^(NSString* path, NSString* subtitle) {
        
        [self addToRecent:[NSString stringWithFormat:@"%@",path] withSelector:@selector(loadSubtitle:)];
        
        NSString* error = [SESingleton preproccessSubtitle:subtitle toArray:[SESingleton shared].content];
        
        if(error)
        {
            NSError* outError = [NSError errorWithDomain:error code:0 userInfo:nil];
            [[NSAlert alertWithError:outError] runModal];
        }
        else
        {
            [[SESingleton shared] reloadData];
            [SESingleton shared].subtitlePath = [NSString stringWithFormat:@"%@",path];
        }
    }];

}

- (void)insertSubtitle:(id)sender
{
    NSString *subtitleString = (NSString*)sender;
    
    if([sender isKindOfClass:[NSMenuItem class]])
    {
        subtitleString = [(NSMenuItem*)sender title];
    }
    
    [SELoadSubtitleWindow createWithFilePath:subtitleString finishBlock:^(NSString* path, NSString* subtitle) {
        
        //[self addToRecent:[NSString stringWithFormat:@"%@",path] WithSelector:@selector(loadSubtitle:)];
        
        NSMutableArray* array = [NSMutableArray array];
        
        NSString* error = [SESingleton preproccessSubtitle:subtitle toArray:array];
        
        double plus = (double)[SESingleton shared].timeLineView.currentTime;
        
        for(SENode* node in array)
        {
            node.startTime += plus;
            node.endTime += plus;
        }
        
        [[SESingleton shared].content addObjectsFromArray:array];
        [[SESingleton shared] shortContentByTime];
        
        if(error)
        {
            NSError* outError = [NSError errorWithDomain:error code:0 userInfo:nil];
            [[NSAlert alertWithError:outError] runModal];
        }
        else
        {
            [[SESingleton shared] reloadData];
            [SESingleton shared].timeLineView.currentTime = plus;
            [SESingleton shared].subtitlePath = [NSString stringWithFormat:@"%@",path];
        }
    }];
}

- (IBAction)saveSubtitleAs:(id)sender
{
    NSSavePanel* saveDlg = [NSSavePanel savePanel];
    NSArray *types = [[NSArray alloc] initWithObjects:@"srt", nil];
	[saveDlg setAllowedFileTypes:types];
	saveDlg.allowedFileTypes = types;

    if ([saveDlg runModal] == NSModalResponseOK)
	{
		NSString *file = [[saveDlg URL] path];
        [SELoadSubtitleWindow createSaveWithPath:file];
    }
}

- (IBAction)newSubtitle:(id)sender
{
    [self closeSubtitle:sender];
}

- (IBAction)saveSubtitle:(id)sender
{
    if([SESingleton shared].subtitlePath)
    {
        NSString* outString = [SESingleton stringOfAllSubtitle];
        NSError* outError = nil;
        [outString writeToFile:[SESingleton shared].subtitlePath atomically:YES encoding:[SESingleton shared].encoding error:&outError];
        
        if(outError)
        {
            [[NSAlert alertWithError:outError] runModal];
        }
    }
    else
    {
        [self saveSubtitleAs:sender];
    }
}

- (IBAction)undo:(id)sender
{
    NSAlert* alert = [NSAlert new];
    alert.messageText = @"Just kidding! It is unavailable!";
    [alert runModal];
}

- (IBAction)closeSubtitle:(id)sender
{
    [SESingleton shared].subtitlePath = nil;
    [[SESingleton shared].content removeAllObjects];
    [[SESingleton shared] reloadData];
    
    [SESingleton shared].mainWindow.title = [NSString stringWithFormat:@"SubEdit"];
}

- (IBAction)closeVideo:(id)sender
{
    [[[SESingleton shared] movieView] closeMovie];
    [[SESingleton shared] setMovieVolume:0.0];
}

- (IBAction)openSubtitleFromTxt:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray *types = [[NSArray alloc] initWithObjects:@"txt", nil];
	[openDlg setAllowedFileTypes:types];
	openDlg.allowedFileTypes = types;
	//[openDlg setAllowsOtherFileTypes:YES];
	
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:YES];
	
	// Enable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:NO];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ([openDlg runModal] == NSModalResponseOK)
	{
		NSString *file = [[openDlg URL] path];
        
        [SELoadSubtitleWindow createWithFilePath:file finishBlock:^(NSString* path, NSString* subtitle) {
            
            double msec = 0;
            double offset = 2.0;
            
            NSArray* array = [subtitle componentsSeparatedByString:@"\n"];
            
            for(NSString * str in array)
            {
                SENode* node = [SENode new];

                node.textProblem = NO;
                node.startTime = (double)msec / 1000.0;
                node.endTime = (msec + offset) / 1000.0;
                
                msec += (offset + 0.05);
                
                if(str)
                {
                    node.text = [NSString stringWithFormat:@"%@",str];
                }
                else
                {
                    node.text = @"";
                }
                [[SESingleton shared].content addObject:node];
            }
            
            [[SESingleton shared] reloadData];
            [SESingleton shared].mainWindow.title = [NSString stringWithFormat:@"%@",path];
            
            /*
            NSString* error = [SESingleton preproccessSubtitle:subtitle toArray:[SESingleton shared].content];
            
            if(error)
            {
                NSError* outError = [NSError errorWithDomain:error code:0 userInfo:nil];
                [[NSAlert alertWithError:outError] runModal];
            }
            else
            {
                [[SESingleton shared] reloadData];
                [SESingleton shared].mainWindow.title = [NSString stringWithFormat:@"%@",path];
            }*/
        }];
    }
}

- (IBAction)insertASubtitle:(id)sender
{
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    NSArray *types = [[NSArray alloc] initWithObjects:@"srt",@"SRT", nil];
	[openDlg setAllowedFileTypes:types];
	openDlg.allowedFileTypes = types;
	//[openDlg setAllowsOtherFileTypes:YES];
	
	// Enable the selection of files in the dialog.
	[openDlg setCanChooseFiles:YES];
	
	// Enable the selection of directories in the dialog.
	[openDlg setCanChooseDirectories:NO];
	
	// Display the dialog.  If the OK button was pressed,
	// process the files.
	if ([openDlg runModal] == NSModalResponseOK)
	{
		NSString *file = [[openDlg URL] path];
        [self insertSubtitle:file];
    }

}

@end
