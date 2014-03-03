//
//  ViewController.m
//  SpringCollectionView
//
//  Created by Thodoris on 03/03/14.
//  Copyright (c) 2014 72lions. All rights reserved.
//

#import "ViewController.h"
#import "SpringCollectionViewFlowLayout.h"
#import "CustomCell.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end

@implementation ViewController

static NSString *CellIdentifier = @"SpringyCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.collectionView registerClass:[CustomCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.collectionView.collectionViewLayout = [[SpringCollectionViewFlowLayout alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

-(CustomCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell setTitle:[NSString stringWithFormat:@"%d", indexPath.row]];
    return cell;
}

@end
