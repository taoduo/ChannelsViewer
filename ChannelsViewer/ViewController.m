//
//  ViewController.m
//  ChannelsViewer
//
//  Created by Duo Tao on 8/6/16.
//  Copyright © 2016 Duo Tao. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize imageView;
@synthesize countLabel;
@synthesize channelLabel;
@synthesize linesBox;
@synthesize chanTable;
@synthesize currentChannels;

NSMutableArray *fileList;
signed int currentIndex;
int total;
NSMutableDictionary *freqChanMap;

- (void)viewDidLoad {
    [super viewDidLoad];
    freqChanMap = [[NSMutableDictionary alloc] init];
    fileList = [NSMutableArray array];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    // NSLog(@"num:%d",  (int)[currentChannels count]);
    return [currentChannels count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // NSLog(@"%@", currentChannels[row]);
    return currentChannels[row];
}

/**
 * views to update: image, channel label and index / count lable
 */
- (void) updateView {
    if (currentIndex < 0) {
        currentIndex = 0;
    }
    NSURL *url = fileList[currentIndex];
    NSImage *image = [[NSImage alloc]initWithContentsOfFile:[url path]];
    [imageView setImage:image];
    NSString *text = [NSString stringWithFormat:@"%d / %d", currentIndex, total];
    [countLabel setStringValue:text];
    [channelLabel setStringValue: [[fileList[currentIndex] absoluteString] lastPathComponent]];
}

/**
 * load the folder at path
 * folder contains a lines.txt which has all the frequencies of the lines to look at and many jpg files.
 */
- (void)loadFolder: (NSString*) path {
    [fileList removeAllObjects];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:nil];
    NSString *p;
    NSString *ext;
    for (NSURL *url in enumerator) {
        p = [url path];
        ext = [p pathExtension];
        if ([ext isEqualToString:@"txt"]) {
            [self readFrequency: url];
        }
        if ([ext isEqualToString:@"jpg"]) {
            [fileList addObject: url];
        }
    }
    currentIndex = -1;
    total = (int) [fileList count] - 1;
    [self updateView];
}

/**
 * Read the frequencies of the lines at url, a txt file
 * txt file format eg.
 * 13.5
 * 19.5
 * 909.232
 */
- (void)readFrequency: (NSURL*) url {
    [linesBox removeAllItems];
    [freqChanMap removeAllObjects];
    NSString *str = [NSString stringWithContentsOfFile:[url path] encoding:NSUTF8StringEncoding error: nil];
    NSArray *freqstr=[str componentsSeparatedByString:@"\n"];
    for (NSString *str in freqstr) {
        freqChanMap[str] = [[NSMutableArray alloc] init];
        [linesBox addItemWithObjectValue:str];
    }
    [linesBox selectItemAtIndex:0];
    currentChannels = freqChanMap[[linesBox objectValueOfSelectedItem]];
    [linesBox setNumberOfVisibleItems: [freqstr count]];
}

/**
 * import button click event: get the path and load the folder
 */
- (IBAction)importButtonClick:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL* url = [[panel URLs] firstObject];
            if (url.isFileURL) {
                BOOL isDir = NO;
                if ([[NSFileManager defaultManager] fileExistsAtPath: url.path isDirectory: &isDir]
                    && isDir) {
                    // Here you can be certain the url exists and is a directory
                    [self loadFolder: [url path]];
                }
            }
        }
    }];
}

- (IBAction)nextButtonClick:(id)sender {
    int count = (int) [fileList count];
    if (currentIndex < (count - 1)) {
        currentIndex++;
        [self updateView];
    }
}

- (IBAction)prevButtonClick:(id)sender {
    if (currentIndex > 0) {
        currentIndex--;
        [self updateView];
    }
}

- (IBAction)addButtonClick:(id)sender {
    /* NSString *selectedItem = [linesBox objectValueOfSelectedItem];
    NSMutableArray *channels = [freqChanMap objectForKey:selectedItem]; */
    // get the channel name (file name)
    NSString *channelName = [[fileList[currentIndex] URLByDeletingPathExtension] lastPathComponent];
    if ([channelName hasSuffix:@"_data"]) {
        int sl = (int) [@"_data" length];
        channelName = [channelName substringToIndex:[channelName length] - sl - 1];
    }
    [currentChannels addObject:channelName];
    // NSLog(@"%d", (int) [currentChannels count]);
    [chanTable reloadData];
}

-(IBAction)selectedLineChange:(id)sender {
    NSComboBox* cb = (NSComboBox*) sender;
    NSString *si = [cb objectValueOfSelectedItem];
    currentChannels = [freqChanMap valueForKey:si];
    [chanTable reloadData];
}

-(IBAction)exportButtonClick:(id)sender {
    NSString *filename = @"summary";
    for (id key in freqChanMap) {
        filename = [NSString stringWithFormat:@"%@_%@", filename, key];
    }
    filename = [NSString stringWithFormat:@"%@_%@", filename, @".txt"];
    [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    NSString *toWrite = @"Summary";
    for (id key in freqChanMap) {
        toWrite = [NSString stringWithFormat:@"%@%@", toWrite, [NSString stringWithFormat:@"\n--- %@ Hz ---\n", key]];
        NSMutableArray *chns = [freqChanMap valueForKey:key];
        for (NSString* c in chns) {
            toWrite = [NSString stringWithFormat:@"%@%@", toWrite, [NSString stringWithFormat:@"%@\n", c]];
        }
    }
    BOOL success = [toWrite writeToFile:filename atomically:true encoding:NSUTF8StringEncoding error:nil];
    if (success) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Export Complete"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert runModal];
    }
}
@end
