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

NSMutableArray *fileList;
signed int currentIndex;
int total;

- (void)viewDidLoad {
    [super viewDidLoad];
}

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

- (void)loadFolder: (NSString*) path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL URLWithString:path]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSDirectoryEnumerator *enumerator = [fileManager
                                         enumeratorAtURL:directoryURL
                                         includingPropertiesForKeys:keys
                                         options:0
                                         errorHandler:nil];
    fileList = [NSMutableArray array];
    for (NSURL *url in enumerator) {
        [fileList addObject:url];
    }
    currentIndex = -1;
    total = (int) [fileList count] - 1;
    [self updateView];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)importButtonClick:(id)sender {
    NSOpenPanel*    panel = [NSOpenPanel openPanel];
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
@end
