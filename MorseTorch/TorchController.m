//
//  TorchController.m
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/16/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "TorchController.h"
#import <AVFoundation/AVFoundation.h>
#import "NSString+MorseCode.h"

@interface TorchController ()

@property (nonatomic, strong) AVCaptureDevice *myDevice;
@property (nonatomic, strong) NSOperationQueue *flashQueue;

@end

@implementation TorchController

-(id)init
{
    self = [super init];
    if (self){
        self.flashQueue = [NSOperationQueue new];
        self.myDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        self.flashQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)convertMorseCode:(NSString *)morseString
{
    
    NSMutableArray *translatedSymbolsArray = [NSString morseSymbolsForString:morseString];
    
    for (NSString *morseLetter in translatedSymbolsArray) {
        [self.flashQueue addOperationWithBlock:^{
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.delegate displayNewLetter:[NSString letterForSymbol:morseLetter]];
            }];
        }];
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
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate doneTransmitting];
        }];
    }];
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

-(void)cancelSending
{
    [self.flashQueue cancelAllOperations];
}

@end
