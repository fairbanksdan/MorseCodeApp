//
//  CameraController.m
//  MorseTorch
//
//  Created by Daniel Fairbanks on 4/17/14.
//  Copyright (c) 2014 Fairbanksdan. All rights reserved.
//

#import "CameraController.h"
#import <AVFoundation/AVFoundation.h>

#define NUMBER_OF_FRAME_PER_S 30
#define BRIGHTNESS_THRESHOLD 70
#define MIN_BRIGHTNESS_THRESHOLD 10

@interface CameraController() <AVCaptureAudioDataOutputSampleBufferDelegate>

{
    AVCaptureSession *_captureSession;
    int  _lastTotalBrightnessValue;
    int _brightnessThreshold;
    BOOL _started;
}

@end

@implementation CameraController

- (id)init
{
    if ((self = [super init])) { [self initMagicEvents];}
    return self;
}

- (void)initMagicEvents
{
    _started = NO;
    _brightnessThreshold = BRIGHTNESS_THRESHOLD;
    
    [NSThread detachNewThreadSelector:@selector(initCapture) toTarget:self withObject:nil];
}

- (void)initCapture {
    
    NSError *error = nil;
    
    AVCaptureDevice *captureDevice = [self searchForBackCameraIfAvailable];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if ( ! videoInput)
    {
        NSLog(@"Could not get video input: %@", error);
        return;
    }
    
    
    //  the capture session is where all of the inputs and outputs tie together.
    
    _captureSession = [[AVCaptureSession alloc] init];
    
    //  sessionPreset governs the quality of the capture. we don't need high-resolution images,
    //  so we'll set the session preset to low quality.
    
    _captureSession.sessionPreset = AVCaptureSessionPresetLow;
    
    [_captureSession addInput:videoInput];
    
    //  create the thing which captures the output
    AVCaptureVideoDataOutput *videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    //  pixel buffer format
//    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
//                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA],
//                              kCVPixelBufferPixelFormatTypeKey, nil];
//    videoDataOutput.videoSettings = settings;
//    
    if ( [captureDevice lockForConfiguration:NULL] == YES)  {
        [captureDevice setExposureMode:AVCaptureExposureModeLocked];
        [captureDevice setActiveVideoMinFrameDuration:CMTimeMake(1, NUMBER_OF_FRAME_PER_S)];
        [captureDevice unlockForConfiguration];
    }
    
//    AVCaptureConnection *conn = [videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
//    if (conn.isVideoMinFrameDurationSupported)
//        conn.videoMinFrameDuration = CMTimeMake(1, NUMBER_OF_FRAME_PER_S);
//    if (conn.isVideoMaxFrameDurationSupported)
//        conn.videoMaxFrameDuration = CMTimeMake(1, NUMBER_OF_FRAME_PER_S);
    
    //  we need a serial queue for the video capture delegate callback
    dispatch_queue_t queue = dispatch_queue_create("com.zuckerbreizh.cf", NULL);
    
    [videoDataOutput setSampleBufferDelegate:(id)self queue:queue];
    [_captureSession addOutput:videoDataOutput];
    
    [_captureSession startRunning];
    _started = YES;
    
}

-(void)updateBrightnessThreshold:(int)pValue
{
    _brightnessThreshold = pValue;
}

-(BOOL)startCapture
{
    if(!_started){
        _lastTotalBrightnessValue = 0;
        [_captureSession startRunning];
        _started = YES;
    }
    return _started;
}

-(BOOL)stopCapture
{
    if(_started){
        [_captureSession stopRunning];
        _started = NO;
    }
    return _started;
}

#pragma mark - Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess)
    {
        UInt8 *base = (UInt8 *)CVPixelBufferGetBaseAddress(imageBuffer);
        
        //  calculate average brightness in a simple way
        
        size_t bytesPerRow      = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width            = CVPixelBufferGetWidth(imageBuffer);
        size_t height           = CVPixelBufferGetHeight(imageBuffer);
        UInt32 totalBrightness  = 0;
        
        for (UInt8 *rowStart = base; height; rowStart += bytesPerRow, height --)
        {
            size_t columnCount = width;
            for (UInt8 *p = rowStart; columnCount; p += 4, columnCount --)
            {
                UInt32 value = (p[0] + p[1] + p[2]);
                totalBrightness += value;
            }
        }
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        
        if(_lastTotalBrightnessValue==0) _lastTotalBrightnessValue = totalBrightness;
        
        if([self calculateLevelOfBrightness:totalBrightness]<_brightnessThreshold)
        {
            
            
            if([self calculateLevelOfBrightness:totalBrightness]>MIN_BRIGHTNESS_THRESHOLD)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onMagicEventDetected" object:nil];
            }
            else //Mobile phone is probably on a table (too dark - camera obturated)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"onMagicEventNotDetected" object:nil];
            }
            
            NSLog(@"%d",[self calculateLevelOfBrightness:totalBrightness]);
            
        }
        else{
            _lastTotalBrightnessValue = totalBrightness;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"onMagicEventNotDetected" object:nil];
        }
    }
}

-(int) calculateLevelOfBrightness:(int) pCurrentBrightness
{
    return (pCurrentBrightness*100) /_lastTotalBrightnessValue;
}



#pragma mark - Tools
- (AVCaptureDevice *)searchForBackCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}
@end
