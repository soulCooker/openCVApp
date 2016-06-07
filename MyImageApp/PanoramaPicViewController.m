//
//  PanoramaPicViewController.m
//  MyImageApp
//
//  Created by Mark on 16/6/4.
//  Copyright © 2016年 Mark. All rights reserved.
//

#import "PanoramaPicViewController.h"

@interface PanoramaPicViewController ()
@property (nonatomic) UIImageView* panoPic;
@property (nonatomic, weak) UIImage* stitchedimage;
@end

@implementation PanoramaPicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spinner startAnimating];
    [self.spinner setHidesWhenStopped:true];
}
//修改图片的分辨率
- ( UIImage *)imageWithImageSimple:( UIImage *)image scaledToSize:( CGSize )newSize

{
    
    // Create a graphics image context
    
    UIGraphicsBeginImageContext (newSize);
    
    // Tell the old image to draw in this new context, with the desired
    
    // new size
    
    [image drawInRect : CGRectMake ( 0 , 0 ,newSize. width ,newSize. height )];
    
    // Get the new image from the context
    
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext ();
    
    // End the context
    
    UIGraphicsEndImageContext ();
    
    // Return the new image.
    
    return newImage;
    
}

- (void)stitch
{
    NSMutableArray* imageSample = [[NSMutableArray alloc] init];
    
    for(UIImage* image in self.selImages)
    {
        CGFloat width = image.size.width, height = image.size.height;
        CGSize size = CGSizeMake(width*720/height, 720);
        [imageSample addObject:[self imageWithImageSimple:image scaledToSize:size]];
    }
    
    self.stitchedimage=[CVWrapper processWithArray:imageSample];
    if (self.stitchedimage.size.width == 0) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                       message:@"全景图合成失败"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                              handler:nil];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        [self.panoPic setNeedsLayout];
        // Do any additional setup after loading the view.
        [self.spinner stopAnimating];
        [self dismissViewControllerAnimated:true completion:nil];
    }
    else{
        self.panoPic = [[UIImageView alloc] initWithImage:self.stitchedimage];
        [self.scrollView addSubview:self.panoPic];
        self.scrollView.backgroundColor = [UIColor blackColor];
        self.scrollView.maximumZoomScale = 1.0;
        self.scrollView.minimumZoomScale = self.view.bounds.size.width/self.panoPic.image.size.width;
        self.scrollView.contentScaleFactor = self.scrollView.minimumZoomScale;
        self.scrollView.contentOffset = CGPointMake(-(self.scrollView.bounds.size.width-self.panoPic.bounds.size.width)/2, -(self.scrollView.bounds.size.height-self.panoPic.bounds.size.height)/2);
        self.scrollView.delegate = self;
        [self.panoPic setNeedsLayout];
        // Do any additional setup after loading the view.
        [self.spinner stopAnimating];
    }

}

- (void) viewDidAppear:(BOOL)animated
{
    if(self.panoPic == nil)
        [self stitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.panoPic;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //SaveSharePicViewController* ssPic = segue.destinationViewController;
    UIImageWriteToSavedPhotosAlbum([self.panoPic image], nil, nil, nil);
    //ssPic
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
