//
//  MorseReceiverVC.h
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/17/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MorseReceiverVC : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *startReceivingMessage;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong) AVCaptureDevice *videoDevice;
@property (strong) AVCaptureDeviceInput *videoInput;
@property (strong) AVCaptureStillImageOutput *stillImageOutput;

- (void)setupCaptureSession;



@end
