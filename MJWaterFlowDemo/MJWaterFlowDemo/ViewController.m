//
//  ViewController.m
//  MJWaterFlowDemo
//
//  Created by 王梦杰 on 16/1/23.
//  Copyright (c) 2016年 Mooney_wang. All rights reserved.
//

#import "ViewController.h"
#import "MJWaterFlowCell.h"
#import "MJWaterFlowView.h"
#import "MJDetailViewController.h"

@interface ViewController () <MJWaterFlowViewDataSource,MJWaterFlowViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MJWaterFlowView *waterFlowView = [[MJWaterFlowView alloc] init];
    waterFlowView.frame = self.view.bounds;
    waterFlowView.delegate = self;
    waterFlowView.dataSource = self;
    
    //由于waterflowView的reloadData方法会在这一句调完之后调用，为了防止reloadData方法调用的时候还没有设置数据源和代理，以及frame，所以这句话应放在最后面(这是一个坑，写完之后也被坑过，有时间再研究一下)
    [self.view addSubview:waterFlowView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MJWaterFlowViewDataSource

- (NSUInteger)numberOfCellsInWaterFlowView:(MJWaterFlowView *)waterFlowView{
    return 30;
}

- (MJWaterFlowCell *)waterFlowView:(MJWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index{
    static NSString *cellID = @"waterFlowCellID";
    MJWaterFlowCell *cell = [waterFlowView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[MJWaterFlowCell alloc] initWithReuseIdentifier:cellID];
    }
    cell.backgroundColor = [UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0];
    return cell;
}

- (NSUInteger)numberOfColumnsInWaterFlowView:(MJWaterFlowView *)waterFlowView{
    return 3;
}

#pragma mark MJWaterFlowViewDelegate

- (CGFloat)waterFlowView:(MJWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index{
    if (index % 2 == 0) {
        return 180;
    }
    return 160;
}

- (void)waterFlowView:(MJWaterFlowView *)waterFlowView didSelectAtIndex:(NSUInteger)index{
    MJDetailViewController *detailViewController = [[MJDetailViewController alloc] init];
    detailViewController.view.backgroundColor = [UIColor whiteColor];
    detailViewController.title = [NSString stringWithFormat:@"detail - %ld",index];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (CGFloat)waterFlowView:(MJWaterFlowView *)waterFlowView marginForType:(MJWaterFlowViewMarginType)type{
    return 10;
}

@end
