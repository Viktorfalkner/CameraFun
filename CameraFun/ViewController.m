//
//  ViewController.m
//  CameraFun
//
//  Created by Viktor on 10/20/14.
//  Copyright (c) 2014 AD. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIButton *pictureButton;
@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *cameraView;

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated  {
    [super viewDidAppear:animated];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    self.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    self.imagePicker.showsCameraControls = NO;
    //    self.imagePicker.navigationBarHidden = YES;
    
    [self initializeSubviews];
    [self applyConstraints];
    [self applyStyles];
    
    [self presentViewController:self.imagePicker animated:YES completion:^{
    }];
    
    [self.pictureButton addTarget:self action:@selector(pictureButtonPressed) forControlEvents:UIControlEventAllEvents];
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)initializeSubviews {
    self.overlay = [[UIView alloc]init];
    self.overlay.backgroundColor = [UIColor clearColor];
    self.overlay.frame = self.imagePicker.cameraOverlayView.bounds;
    self.imagePicker.cameraOverlayView = self.overlay;
    
    self.topView = [[UIView alloc]init];
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    self.topView.backgroundColor = [UIColor blackColor];
    [self.overlay addSubview:self.topView];
    
    self.bottomView = [[UIView alloc]init];
    self.bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomView.backgroundColor = [UIColor blackColor];
    [self.overlay addSubview:self.bottomView];
    
    self.pictureButton = [[UIButton alloc]init];
    self.pictureButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.pictureButton.backgroundColor = [UIColor whiteColor];
    [self.bottomView addSubview:self.pictureButton];
    
    self.cameraView = [[UIView alloc]init];
    self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.overlay addSubview:self.cameraView];
}

- (void)applyConstraints {
    NSDictionary *subviews = @{
                               @"topView" : self.topView,
                               @"bottomView" : self.bottomView,
                               @"pictureButton" : self.pictureButton,
                               @"cameraView" : self.cameraView,
                               };
    
    
    NSArray *topViewVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(==44)][cameraView][bottomView(==94)]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:subviews];
    [self.overlay addConstraints:topViewVertical];
    
    NSArray *topViewHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:subviews];
    [self.overlay addConstraints:topViewHorizontal];
    
    
    NSArray *cameraViewHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[cameraView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews];
    [self.overlay addConstraints:cameraViewHorizontal];
    
    NSArray *bottomViewHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomView]|"
                                                                            options:0
                                                                            metrics:nil
                                                                              views:subviews];
    [self.overlay addConstraints:bottomViewHorizontal];
    
    
    NSArray *pictureButtonVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[pictureButton(==40)]"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:subviews];
    [self.bottomView addConstraints:pictureButtonVertical];
    
    NSLayoutConstraint *pictureButtonCenterY = [NSLayoutConstraint constraintWithItem:self.pictureButton
                                                                            attribute:NSLayoutAttributeCenterY
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.bottomView
                                                                            attribute:NSLayoutAttributeCenterY
                                                                           multiplier:1.0
                                                                             constant:0];
    [self.bottomView addConstraint:pictureButtonCenterY];
    
    NSLayoutConstraint *pictureButtonCenterX = [NSLayoutConstraint constraintWithItem:self.pictureButton
                                                                            attribute:NSLayoutAttributeCenterX
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.bottomView
                                                                            attribute:NSLayoutAttributeCenterX
                                                                           multiplier:1.0
                                                                             constant:0];
    [self.bottomView addConstraint:pictureButtonCenterX];
}

- (void)applyStyles {
    self.topView.backgroundColor = [UIColor blackColor];
    
    self.bottomView.backgroundColor = [UIColor blackColor];
    
    self.pictureButton.backgroundColor = [UIColor whiteColor];
    
    self.cameraView.layer.borderColor = [UIColor redColor].CGColor;
    self.cameraView.layer.borderWidth = 2;
    
}

- (void)pictureButtonPressed {
    [self.imagePicker takePicture];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"])
    {
        UIImage *imagePicked = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CGSize imageSize = imagePicked.size;
        CGFloat scale = imageSize.width/screenSize.width;
        CGRect cameraBounds = self.cameraView.bounds;
        cameraBounds.size.width *= scale;
        cameraBounds.size.height *= scale;
        
        imagePicked = [UIImage imageWithCGImage:imagePicked.CGImage scale:imagePicked.scale orientation:UIImageOrientationUp];
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([imagePicked CGImage], cameraBounds);
        UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
        
        
        CGImageRelease(imageRef);
        
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil);
        
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


//CGRect transformCGRectForUIImageOrientation(CGRect source, UIImageOrientation orientation, CGSize imageSize) {
//    switch (orientation) {
//        case UIImageOrientationLeft: { // EXIF #8
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
//            return CGRectApplyAffineTransform(source, txCompound);
//        }
//        case UIImageOrientationDown: { // EXIF #3
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
//            return CGRectApplyAffineTransform(source, txCompound);
//        }
//        case UIImageOrientationRight: { // EXIF #6
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI + M_PI_2);
//            return CGRectApplyAffineTransform(source, txCompound);
//        }
//        case UIImageOrientationUp: // EXIF #1 - do nothing
//        default: // EXIF 2,4,5,7 - ignore
//            return source;
//    }
//    
//}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertView *alert;
    
    // Unable to save the image
    if (error)
        alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                           message:@"Unable to save image to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    else // All is well
        alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                           message:@"Image saved to Photo Album."
                                          delegate:self cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
    [alert show];
    
}


//-(UIImage *)cropImage:(UIImage *)sourceImage cropRect:(CGRect)cropRect aspectFitBounds:(CGSize)finalImageSize fillColor:(UIColor *)fillColor {
//
//    CGImageRef sourceImageRef = sourceImage.CGImage;
//
//    //Since the crop rect is in UIImageOrientationUp we need to transform it to match the source image.
//    CGAffineTransform rectTransform = [self transformSize:sourceImage.size orientation:sourceImage.imageOrientation];
//    CGRect transformedRect = CGRectApplyAffineTransform(cropRect, rectTransform);
//
//    //Now we get just the region of the source image that we are interested in.
//    CGImageRef cropRectImage = CGImageCreateWithImageInRect(sourceImageRef, transformedRect);
//
//    //Figure out which dimension fits within our final size and calculate the aspect correct rect that will fit in our new bounds
//    CGFloat horizontalRatio = finalImageSize.width / CGImageGetWidth(cropRectImage);
//    CGFloat verticalRatio = finalImageSize.height / CGImageGetHeight(cropRectImage);
//    CGFloat ratio = MIN(horizontalRatio, verticalRatio); //Aspect Fit
//    CGSize aspectFitSize = CGSizeMake(CGImageGetWidth(cropRectImage) * ratio, CGImageGetHeight(cropRectImage) * ratio);
//
//
//    CGContextRef context = CGBitmapContextCreate(NULL,
//                                                 finalImageSize.width,
//                                                 finalImageSize.height,
//                                                 CGImageGetBitsPerComponent(cropRectImage),
//                                                 0,
//                                                 CGImageGetColorSpace(cropRectImage),
//                                                 CGImageGetBitmapInfo(cropRectImage));
//
//    if (context == NULL) {
//        NSLog(@"NULL CONTEXT!");
//    }
//
//    //Fill with our background color
//    CGContextSetFillColorWithColor(context, fillColor.CGColor);
//    CGContextFillRect(context, CGRectMake(0, 0, finalImageSize.width, finalImageSize.height));
//
//    //We need to rotate and transform the context based on the orientation of the source image.
//    CGAffineTransform contextTransform = [self transformSize:finalImageSize orientation:sourceImage.imageOrientation];
//    CGContextConcatCTM(context, contextTransform);
//
//    //Give the context a hint that we want high quality during the scale
//    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//
//    //Draw our image centered vertically and horizontally in our context.
//    CGContextDrawImage(context, CGRectMake((finalImageSize.width-aspectFitSize.width)/2, (finalImageSize.height-aspectFitSize.height)/2, aspectFitSize.width, aspectFitSize.height), cropRectImage);
//
//    //Start cleaning up..
//    CGImageRelease(cropRectImage);
//
//    CGImageRef finalImageRef = CGBitmapContextCreateImage(context);
//    UIImage *finalImage = [UIImage imageWithCGImage:finalImageRef];
//
//    CGContextRelease(context);
//    CGImageRelease(finalImageRef);
//    return finalImage;
//}
//
////Creates a transform that will correctly rotate and translate for the passed orientation.
////Based on code from niftyBean.com
//- (CGAffineTransform) transformSize:(CGSize)imageSize orientation:(UIImageOrientation)orientation {
//
//    CGAffineTransform transform = CGAffineTransformIdentity;
//    switch (orientation) {
//        case UIImageOrientationLeft: { // EXIF #8
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI_2);
//            transform = txCompound;
//            break;
//        }
//        case UIImageOrientationDown: { // EXIF #3
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,M_PI);
//            transform = txCompound;
//            break;
//        }
//        case UIImageOrientationRight: { // EXIF #6
//            CGAffineTransform txTranslate = CGAffineTransformMakeTranslation(0.0, imageSize.width);
//            CGAffineTransform txCompound = CGAffineTransformRotate(txTranslate,-M_PI_2);
//            transform = txCompound;
//            break;
//        }
//        case UIImageOrientationUp: // EXIF #1 - do nothing
//        default: // EXIF 2,4,5,7 - ignore
//            break;
//    }
//    return transform;
//    
//}


@end
