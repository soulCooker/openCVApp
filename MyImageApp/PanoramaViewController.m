//
//  PanoramaViewController.m
//  MyImageApp
//
//  Created by Mark on 16/5/24.
//  Copyright © 2016年 Mark. All rights reserved.
//

#import "PanoramaViewController.h"

@interface PanoramaViewController ()
@property (nonatomic) MHImagePickerMutilSelector *imagePickerMutilSelector;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIView *cameraLayoutView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *startstopTakePic;
@property (nonatomic, weak) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UILabel *picCountlb;
@property (nonatomic) NSInteger picCount;

@end

@implementation PanoramaViewController

//delegate to MHImagePickerMutilSelector
-(void)imagePickerMutilSelectorDidGetImages:(NSArray *)imageArray
{
    if (self.capturedImage.count > 0)
    {
        [self.capturedImage removeAllObjects];
    }
    self.capturedImage =[[NSMutableArray alloc] initWithArray:imageArray copyItems:YES];
    [self.collectionView reloadData];
}

//UICollectionViewDelegate

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.capturedImage.count;
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"selImage" forIndexPath:indexPath];
    UIImageView *imageView = [[UIImageView alloc]init];
    UIImage *image = self.capturedImage[indexPath.item];
    [imageView setImage:image];
    imageView.frame = cell.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [cell.contentView addSubview:imageView];
    return cell;
}

//PanoramaView

- (IBAction)unwindToPanoView:(UIStoryboardSegue *)segue
{}

- (IBAction)photoLibrary:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}


- (IBAction)camera:(id)sender {
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        if (self.capturedImage.count>0) {
            [self.capturedImage removeAllObjects];
        }
        imagePickerController.showsCameraControls = NO;
        [[NSBundle mainBundle] loadNibNamed:@"CameraLayoutView" owner:self options:nil];
        self.cameraLayoutView.frame = imagePickerController.cameraOverlayView.frame;
        imagePickerController.cameraOverlayView = self.cameraLayoutView;
        self.cameraLayoutView = nil;
        imagePickerController.delegate = self;
    }
    else
    {
        MHImagePickerMutilSelector* imagePickerMutilSelector=[MHImagePickerMutilSelector standardSelector];//自动释放
        imagePickerMutilSelector.delegate=self;//设置代理
        
        imagePickerController.delegate=imagePickerMutilSelector;//将UIImagePicker的代理指向到imagePickerMutilSelector
        [imagePickerController setAllowsEditing:NO];
        imagePickerController.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
        imagePickerController.navigationController.delegate=imagePickerMutilSelector;//将UIImagePicker的导航代理指向到imagePickerMutilSelector
        
        imagePickerMutilSelector.imagePicker=imagePickerController;//使imagePickerMutilSelector得知其控制的UIImagePicker实例，为释放时需要。
        self.imagePickerMutilSelector = imagePickerMutilSelector;
        //[imagePickerController release];
    }
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.capturedImage = [[NSMutableArray alloc]init];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #imagePickerController
*/
- (IBAction)startTakingPicatInterval:(id)sender {
    self.picCount = 0;
    self.startstopTakePic.title = NSLocalizedString(@"Stop", @"Title for overlay view controller start/stop button");
    [self.startstopTakePic setAction:@selector(stopTakingPicatInterval:)];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(timedPhotoFire:) userInfo:nil repeats:YES];
    [self.timer fire];
}

#pragma mark - Timer

// Called by the timer to take a picture.
- (void)timedPhotoFire:(NSTimer *)timer
{
    self.picCount++;
    [self.imagePickerController takePicture];
    NSString *count = [NSString stringWithFormat:@"%ld", (long)self.picCount];
    self.picCountlb.text = count;
    if (self.picCount>=10) {
        [self stopTakingPicatInterval:self];
    }
}

- (IBAction)stopTakingPicatInterval:(id)sender
{
    [self.timer invalidate];
    self.timer = nil;
    [self finishUpdate];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self.capturedImage addObject:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self finishUpdate];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier compare:@"stitchImage"] == YES) {//检查用于拼接的图片数量，不能少于2张
        if (self.capturedImage.count < 2)
        {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                           message:@"图片不能少于两张"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault
                                                                  handler:nil];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            return false;
        }
        else
            return true;
    }
    else
        return true;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender//传递用于合成全景图的图片组
{
    if ([segue.identifier compare:@"stitchImage"] == YES) {
        PanoramaPicViewController* picView = segue.destinationViewController;
        picView.selImages = [[NSMutableArray alloc]initWithArray:self.capturedImage];
    }
}

- (void) finishUpdate
{
    [self.collectionView reloadData];
    [self dismissViewControllerAnimated:YES completion:NULL];
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
