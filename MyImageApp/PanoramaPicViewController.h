//
//  PanoramaPicViewController.h
//  MyImageApp
//
//  Created by Mark on 16/6/4.
//  Copyright © 2016年 Mark. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanoramaViewController.h"
#import "SaveSharePicViewController.h"
#import "CVWrapper.h"
@interface PanoramaPicViewController : UIViewController<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property NSMutableArray *selImages;
@end
