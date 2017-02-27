//
//  ViewController.m
//  TableCellDragAndDrop
//
//  Created by Gupta on 2/22/17.
//  Copyright © 2017 anup. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *NameArray;
    BOOL Edit;
}

@property (weak, nonatomic) IBOutlet UITableView *NameListTableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Edit=NO;
    _NameListTableView.delegate=self;
    _NameListTableView.dataSource=self;
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self.NameListTableView addGestureRecognizer:longPress];
  
    NameArray=[NSMutableArray arrayWithObjects:@"Apple", @"Apricot", @"Banana",@"Bilberry",@"Blackberry",@"Blackcurrant",@"Blueberry", @"Coconut", @"Currant",@"Cherry",@"Cherimoya",@"Clementine",@"Cloudberry",@"Date",@"Damson ",@"Durian ",@"Elderberry",@"Fig ",@"Feijoa ",@" Gooseberry ",@"Grape",@"Grapefruit ",@" Huckleberry ",@" Jackfruit ",@"Jambul ",@" Jujube ",@" Kiwifruit",@" Kumquat ",@" Lemon ",@"Lime ",@"Loquat ", nil];
                        

    
       // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return NameArray.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId=@"NameCell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
    if(cell!=nil)
    {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    
    NSString *abc=[NameArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text=abc;

    
    return cell;
    
    
}

- (IBAction)editAction:(id)sender {
    
    if (Edit==NO) {
         [self.NameListTableView setEditing:YES animated:YES];
        Edit=YES;
    }
    else{
         [self.NameListTableView setEditing:NO animated:YES];
        Edit=NO;
    }
   

}
- (void)longPressGestureRecognized:(id)sender {
    
    UILongPressGestureRecognizer *longPress = (UILongPressGestureRecognizer *)sender;
    UIGestureRecognizerState state = longPress.state;
    
    CGPoint location = [longPress locationInView:self.NameListTableView];
    NSIndexPath *indexPath = [self.NameListTableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                sourceIndexPath = indexPath;
                
                UITableViewCell *cell = [self.NameListTableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshoFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.NameListTableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    cell.alpha = 0.0;
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
                
                // ... update data source.
                [self->NameArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
                
                // ... move the rows.
                [self.NameListTableView moveRowAtIndexPath:sourceIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                sourceIndexPath = indexPath;
                [self.NameListTableView reloadData];

            }
            break;
        }
            
        default: {
            // Clean up.
            UITableViewCell *cell = [self.NameListTableView cellForRowAtIndexPath:sourceIndexPath];
            cell.alpha = 0.0;
            
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                cell.hidden = NO;
                sourceIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
            }];
            
            break;
        }
    }
}

#pragma mark - Helper methods

/** @brief Returns a customized snapshot of a given view. */
- (UIView *)customSnapshoFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

@end
