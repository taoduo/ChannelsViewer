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
NSURL *dataRoot;

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
    dataRoot = [NSURL URLWithString:path];
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
/*
 * Export: a summary txt and all the pictures of the channels
 */
-(IBAction)exportButtonClick:(id)sender {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filename = @"Summary";
    for (id key in freqChanMap) {
        filename = [NSString stringWithFormat:@"%@_%@", filename, key];
    }
    filename = [NSString stringWithFormat:@"%@_%@", filename, @".txt"];
    [[NSFileManager defaultManager] createFileAtPath:filename contents:nil attributes:nil];
    NSString *toWrite = @"Summary";
    for (id key in freqChanMap) {
        toWrite = [NSString stringWithFormat:@"%@%@", toWrite, [NSString stringWithFormat:@"\n--- %@ Hz ---\n", key]];
        NSMutableArray *chns = [freqChanMap valueForKey:key];
        NSURL *targetDir = [NSURL URLWithString:[NSString stringWithFormat:@"line_%@", key]];
        [fileManager createDirectoryAtPath:[targetDir path] withIntermediateDirectories:NO attributes:nil error:nil];
        for (NSString* c in chns) {
            // for summary.txt
            toWrite = [NSString stringWithFormat:@"%@%@", toWrite, [NSString stringWithFormat:@"%@\n", c]];
            // original picture path
            NSURL *fp = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@.jpg", [dataRoot absoluteString], c]];
            // target path
            NSURL *ft = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/%@/%@.jpg", [fileManager currentDirectoryPath], [targetDir absoluteString], c]];
            // copy from origin to targetDir
            NSError *error;
            BOOL s = [fileManager copyItemAtURL:fp toURL:ft error:&error];
            if (!s) {
                NSLog(@"Write failed with error: %@", error);
            }
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
