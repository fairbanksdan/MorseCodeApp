//
//  MorseReceiverVC.m
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/17/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "MorseReceiverVC.h"
#import <AVFoundation/AVFoundation.h>
#import "CameraController.h"

@interface MorseReceiverVC () <CameraControllerDelegate>

@property (strong, nonatomic) CameraController *cameraController;

@end

@implementation MorseReceiverVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.cameraController = [CameraController new];
    self.cameraController.delegate = self;
    
}

- (IBAction)startReceivingMessage:(id)sender {
    [self.cameraController initCapture];
}


@end
