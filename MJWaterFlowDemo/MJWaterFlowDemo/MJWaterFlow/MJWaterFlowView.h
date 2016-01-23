//
//  MJWaterFlowView.h
//  瀑布流
//
//  Created by 王梦杰 on 16/1/12.
//  Copyright (c) 2016年 Mooney_wang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJWaterFlowCell.h"

typedef enum {
    
    MJWaterFlowViewMarginTypeTop,
    MJWaterFlowViewMarginTypeBottom,
    MJWaterFlowViewMarginTypeLeft,
    MJWaterFlowViewMarginTypeRight,
    MJWaterFlowViewMarginTypeColumn,    //列间距
    MJWaterFlowViewMarginTypeRow,       //行间距
    
} MJWaterFlowViewMarginType;

@class MJWaterFlowView;

@protocol MJWaterFlowViewDataSource <NSObject>

@required
/**
 *  一共有多少数据
 */
- (NSUInteger)numberOfCellsInWaterFlowView:(MJWaterFlowView *)waterFlowView;
/**
 *  返回index位置对应的cell
 */
- (MJWaterFlowCell *)waterFlowView:(MJWaterFlowView *)waterFlowView cellAtIndex:(NSUInteger)index;

@optional
/**
 *  一共有多少列
 */
- (NSUInteger)numberOfColumnsInWaterFlowView:(MJWaterFlowView *)waterFlowView;

@end



@protocol MJWaterFlowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  index位置的cell的高度
 */
- (CGFloat)waterFlowView:(MJWaterFlowView *)waterFlowView heightAtIndex:(NSUInteger)index;
/**
 *  选中index位置的cell
 */
- (void)waterFlowView:(MJWaterFlowView *)waterFlowView didSelectAtIndex:(NSUInteger)index;
/**
 *  返回间距
 */
- (CGFloat)waterFlowView:(MJWaterFlowView *)waterFlowView marginForType:(MJWaterFlowViewMarginType)type;


@end

@interface MJWaterFlowView : UIScrollView

/**
 *  数据源
 */
@property(nonatomic ,weak)id<MJWaterFlowViewDataSource> dataSource;
/**
 *  代理
 */
@property(nonatomic ,weak)id<MJWaterFlowViewDelegate> delegate;

/**
 *  刷新数据
 */
- (void)reloadData;

/**
 *  根据重用标记从缓存池获取cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
