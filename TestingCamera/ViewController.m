//
//  ViewController.m
//  TestingCamera
//
//  Created by Hack on 02.11.15.
//  Copyright © 2015 ttconsalting. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView*  frameForCapture;

@property (strong, nonatomic) AVCaptureSession* session;
@property (strong, nonatomic) AVCaptureStillImageOutput* stillImageOutput;

@end



@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showPhotoLibrary:(id)sender {
    
    UIImagePickerController *imagePicker =
    [[UIImagePickerController alloc] init];
    
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [imagePicker setDelegate:self];
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
   
    [self dismissViewControllerAnimated:YES completion:nil];
}







-(void) startWorkPhotoCamera {
    
    self.session = [[AVCaptureSession alloc] init];
    [self.session setSessionPreset:AVCaptureSessionPresetPhoto];
    
    
    AVCaptureDevice* inputDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError* error;
    AVCaptureDeviceInput* deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    
    if ([self.session canAddInput:deviceInput]) {
        [self.session addInput:deviceInput];
    }
    
   
    
    AVCaptureVideoPreviewLayer* previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    
    CALayer* rootLayer = self.view.layer;
    [rootLayer setMasksToBounds:YES];
    
    CALayer *overlayLayer = [CALayer layer];
    
    
    
    CGRect frame = self.frameForCapture.frame;
    previewLayer.frame = frame;
    overlayLayer.frame = frame;
    
    
    [rootLayer insertSublayer:previewLayer atIndex:0];

    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary* outputSettings = @{ AVVideoCodecJPEG : AVVideoCodecKey };
    
    
    self.stillImageOutput.outputSettings = outputSettings;
    [self.session addOutput:self.stillImageOutput];
    
    [self.session startRunning];
    
}



- (IBAction)takePhoto:(id)sender {
    
    AVCaptureConnection* videoConnection  = nil;
    
    
    for (AVCaptureConnection* connection  in self.stillImageOutput.connections) {
        
        for (AVCaptureInputPort* port in [connection inputPorts]) {
            
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        
        if (videoConnection) {
            break;
        }
    }
    
    ///
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
       
        if (imageDataSampleBuffer != NULL) {
            NSData* imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage* image = [UIImage imageWithData:imageData];
            
            // Сохранение в папку приложения
            //NSData *data = UIImageJPEGRepresentation(image, 0.5f);
            //[self saveImageWithData:data withName:@"myPhoto"];
            
            // Сохранение в альбом
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }];
    
}



- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}



- (void)saveImageWithData:(NSData *)imageData withName:(NSString *)name {
   
    NSData *data = imageData;
    NSLog(@"*** SIZE *** : Saving file of size %lu", (unsigned long)[data length]);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:name];
    [fileManager createFileAtPath:fullPath contents:data attributes:nil];
    
}


@end
