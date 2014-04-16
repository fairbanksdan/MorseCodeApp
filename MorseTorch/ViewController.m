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
#import "TorchController.h"
#import <ProgressHUD/ProgressHUD.h>

@interface ViewController () <UITextViewDelegate, TorchControllerDelegate>

@property (nonatomic, strong) NSArray *translatedSymbolsArray;
@property (strong, nonatomic) IBOutlet UIButton *SendMessageButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelMessageButton;
@property (strong, nonatomic) TorchController *torchController;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.torchController = [TorchController new];
    self.torchController.delegate = self;
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
        _cancelMessageButton.enabled = YES;
    } else {
        _SendMessageButton.enabled = NO;
        _cancelMessageButton.enabled = NO;
    }
}

- (IBAction)cancelMessageButton:(id)sender {
    [self.torchController cancelSending];
    [ProgressHUD dismiss];
    [self.SendMessageButton setEnabled:YES];
}

- (IBAction)sendMessageButton:(id)sender {
    [self.SendMessageButton setEnabled:NO];
    [_torchController convertMorseCode:self.messageTextField.text];

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

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

-(void)displayNewLetter:(NSString *)newLetter
{
    [ProgressHUD show:newLetter];
}

-(void)doneTransmitting
{
    [ProgressHUD dismiss];
    [self.SendMessageButton setEnabled:YES];
}
@end
