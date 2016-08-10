//
//  ViewController.h
//  ChannelsViewer
//
//  Created by Duo Tao on 8/6/16.
//  Copyright © 2016 Duo Tao. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (weak) IBOutlet NSComboBox *linesBox;
@property (weak) IBOutlet NSTextField *channelLabel;
@property (weak) IBOutlet NSTextField *countLabel;
@property (weak) IBOutlet NSImageView *imageView;
- (IBAction)importButtonClick:(id)sender;
- (IBAction)nextButtonClick:(id)sender;
- (IBAction)prevButtonClick:(id)sender;

@end