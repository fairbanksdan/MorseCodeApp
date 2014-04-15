//
//  ViewController.m
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/15/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+MorseCode.h"

@interface ViewController () <UITextViewDelegate>

@property (nonatomic, strong) NSArray *translatedSymbolsArray;

@property (nonatomic, strong) AVCaptureDevice *myDevice;

@property (nonatomic, strong) NSOperationQueue *flashQueue;

@property (strong, nonatomic) IBOutlet UIButton *SendMessageButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.myDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.flashQueue = [NSOperationQueue new];
    
    self.flashQueue.maxConcurrentOperationCount = 1;
    
    self.messageTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enableOrDisableButton)
                                                 name:UITextViewTextDidChangeNotification
                                               object:nil];
}

-(void)enableOrDisableButton
{
    if (_messageTextField.text.length > 0) {
        _SendMessageButton.enabled = YES;
    } else {
        _SendMessageButton.enabled = NO;
    }
}


- (IBAction)turnOn:(id)sender {
    self.myDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([self.myDevice hasTorch] && [self.myDevice hasFlash])
        {
            [self.myDevice lockForConfiguration:nil];
            [self.myDevice setTorchMode:AVCaptureTorchModeOn];
            [self.myDevice setFlashMode:AVCaptureFlashModeOn];
            [self.myDevice unlockForConfiguration];
        }
}


- (IBAction)turnOff:(id)sender {
    self.myDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([self.myDevice hasTorch] && [self.myDevice hasFlash])
    {
        [self.myDevice lockForConfiguration:nil];
        [self.myDevice setTorchMode:AVCaptureTorchModeOff];
        [self.myDevice setFlashMode:AVCaptureFlashModeOff];
        [self.myDevice unlockForConfiguration];
    }
}

- (IBAction)sendMessageButton:(id)sender {
    [self.SendMessageButton setEnabled:NO];
    [self convertMorseCode];

    for (NSString *morseLetter in self.translatedSymbolsArray) {
        for (int i=0; i<morseLetter.length; i++) {
            NSString *letter = [morseLetter substringWithRange:NSMakeRange(i, 1)];
            if ([letter isEqualToString:@"."]) {
                [self.flashQueue addOperationWithBlock:^{
                    [self flashDot];
                }];
            } else if ([letter isEqualToString:@"-"]) {
                [self.flashQueue addOperationWithBlock:^{
                    [self flashDash];
                }];
            } else if ([letter isEqualToString:@" "]) {
                [self.flashQueue addOperationWithBlock:^{
                    [self flashWordSpace];
                }];
                
            }
        }
        [self.flashQueue addOperationWithBlock:^{
            [self flashLetterSpace];
        }];
    }
    [self.flashQueue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            [self.SendMessageButton setEnabled:YES];
        }];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)convertMorseCode
{
    self.translatedSymbolsArray = [NSString morseSymbolsForString:self.messageTextField.text];
}

-(void)torchController
{
    usleep(100000);
}

-(void)flashDot
{
    [self.myDevice lockForConfiguration:nil];
    [self.myDevice setTorchMode:AVCaptureTorchModeOn];
    [self.myDevice unlockForConfiguration];
    usleep(100000);
    
    [self.myDevice lockForConfiguration:nil];
    [self.myDevice setTorchMode:AVCaptureTorchModeOff];
    [self.myDevice unlockForConfiguration];
    usleep(100000);
}

-(void)flashDash
{
    [self.myDevice lockForConfiguration:nil];
    [self.myDevice setTorchMode:AVCaptureTorchModeOn];
    [self.myDevice unlockForConfiguration];
    usleep(300000);
    
    [self.myDevice lockForConfiguration:nil];
    [self.myDevice setTorchMode:AVCaptureTorchModeOff];
    [self.myDevice unlockForConfiguration];
    usleep(100000);
}

-(void)flashWordSpace
{
    usleep(400000);
}

-(void)flashLetterSpace
{
    usleep(200000);
}

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

@end
