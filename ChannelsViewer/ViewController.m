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
NSMutableArray *fileList;
signed int currentIndex;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [NSURL URLWithString:@"file:///Users/duotao/Desktop/images"]; // URL pointing to the directory you want to browse
    NSArray *keys = [NSArray arrayWithObject:NSURLIsDirectoryKey];
    NSDirectoryEnumerator *enumerator = [fileManager
                  enumeratorAtURL:directoryURL
                  includingPropertiesForKeys:keys
                  options:0
                  errorHandler:nil];
    fileList = [NSMutableArray array];
    for (NSURL *url in enumerator) {
        NSLog(@"%@", [url absoluteString]);
        [fileList addObject:url];
    }
    currentIndex = -1;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)importButtonClick:(id)sender {
    
}

- (IBAction)nextButtonClick:(id)sender {
    int count = (int) [fileList count];
    if (currentIndex < (count - 1)) {
        currentIndex++;
        NSURL *url = fileList[currentIndex];
        NSImage *image = [[NSImage alloc]initWithContentsOfFile:[url path]];
        [imageView setImage:image];
    }
}

- (IBAction)prevButtonClick:(id)sender {
    if (currentIndex > 0) {
        currentIndex--;
        NSURL *url = fileList[currentIndex];
        NSImage *image = [[NSImage alloc]initWithContentsOfFile:[url path]];
        [imageView setImage:image];
    }
}
@end
