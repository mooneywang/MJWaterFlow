//
//  MJWaterFlowView.m
//  瀑布流
//
//  Created by 王梦杰 on 16/1/12.
//  Copyright (c) 2016年 Mooney_wang. All rights reserved.
//

#define kWaterFlowViewDefaultCellHeight 150;
#define kWaterFlowViewDefaultCellMargin 8;
#define kWaterFlowViewDefaultColumns 3;

#import "MJWaterFlowView.h"
#import "MJWaterFlowCell.h"

@interface MJWaterFlowView ()

/**
 *  存放cell的frame
 */
@property(nonatomic, strong)NSMutableArray *cellFrames;

/**
 *  存放正在展示的cell
 */
@property(nonatomic, strong)NSMutableDictionary *displayingCell;

/**
 *  缓存池（NSSet）用来存放离开屏幕的cell
 */
@property(nonatomic, strong)NSMutableSet *reusableCells;

@end

@implementation MJWaterFlowView

- (NSMutableArray *)cellFrames{
    if (nil == _cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCell{
    if (nil == _displayingCell) {
        _displayingCell = [NSMutableDictionary dictionary];
    }
    return _displayingCell;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    __block MJWaterFlowCell *resuableCell = nil;
    
    //遍历reusableCells
    [self.reusableCells enumerateObjectsUsingBlock:^(MJWaterFlowCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            resuableCell = cell;
            *stop = YES;//停止遍历
        }
    }];
    
    if (resuableCell) {
        //从缓存池移除
        [self.reusableCells removeObject:resuableCell];
    }
    
    return resuableCell;
}

/**
 *  判断frame有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) && (CGRectGetMinY(frame) < self.contentOffset.y + self.frame.size.height);
}

/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)layoutSubviews{
    [super layoutSubviews];
    //向数据源索要对应位置的cell
    NSUInteger numberOfCell = self.cellFrames.count;
    for (int i = 0; i < numberOfCell; i++) {
        //取出i位置的cell的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        //优先从字典中取出i位置的cell
        MJWaterFlowCell *cell = self.displayingCell[@(i)];
        //判断i位置的cell在不在屏幕上
        if ([self isInScreen:cellFrame]) {
            
            if (cell == nil) {//cell不存在，但是需要在屏幕上显示
                MJWaterFlowCell *cell = [self.dataSource waterFlowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                //存放到字典
                [self.displayingCell setObject:cell forKey:@(i)];
            }
            
        }else{
            if (cell) {//cell存在，但是不在屏幕上显示
                //从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingCell removeObjectForKey:@(i)];
                //存放进缓存池
                [self.reusableCells addObject:cell];
            }
            
        }
    }
    
}

- (void)willMoveToSuperview:(UIView *)newSuperview{
    [self reloadData];
}

/**
 *  刷新数据
 *  计算每一个cell的frame
 */
- (void)reloadData{
    //清空之前的所有数据
    [self.displayingCell.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCell removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //cell的总数
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterFlowView:self];
    
    //列数
    NSUInteger numberOfColumns = [self numberOfColumns];
    
    //间距
    CGFloat topM = [self marginOfType:MJWaterFlowViewMarginTypeTop];
    CGFloat bottomM = [self marginOfType:MJWaterFlowViewMarginTypeBottom];
    CGFloat leftM = [self marginOfType:MJWaterFlowViewMarginTypeLeft];
    CGFloat rightM = [self marginOfType:MJWaterFlowViewMarginTypeRight];
    CGFloat columnM = [self marginOfType:MJWaterFlowViewMarginTypeColumn];
    CGFloat rowM = [self marginOfType:MJWaterFlowViewMarginTypeRow];
    
    //用一个C语言数组存放所有列的最大y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    for (int i = 0; i < numberOfCells; i++) {
        //cell处在第几列(最短的一列)
        NSUInteger cellColumn = 0;
        //cell所处列的最大y值(最短的一列的最大y值)
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        //求出最短的一列
        for (int j = 0; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        CGFloat cellH = [self heightAtIndex:i];
        CGFloat cellW = (self.frame.size.width - leftM - rightM - (numberOfColumns - 1) * columnM) / numberOfColumns;
        CGFloat cellX = leftM + cellColumn * (cellW + columnM);
        CGFloat cellY = 0;
        
        if (maxYOfCellColumn == 0) {//首行
            cellY = topM;
        }else{
            cellY = maxYOfCellColumn + rowM;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        //添加cellFrame到数组中
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        //更新最短那列的y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    }
    
    //设置contentSize
    CGFloat contentH = 0;
    for (int i = 0; i < numberOfColumns; i++) {
        if (maxYOfColumns[i] > contentH) {
            contentH = maxYOfColumns[i];
        }
    }
    
    self.contentSize = CGSizeMake(0, contentH);
    
    
}

#pragma mark - private methods

- (CGFloat)heightAtIndex:(NSUInteger)index{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:heightAtIndex:)]) {
        return [self.delegate waterFlowView:self heightAtIndex:index];
    }else{
        return kWaterFlowViewDefaultCellHeight;
    }
}

- (NSUInteger)numberOfColumns{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterFlowView:)]) {
        return [self.dataSource numberOfColumnsInWaterFlowView:self];
    }else{
        return kWaterFlowViewDefaultColumns;
    }
}

- (CGFloat)marginOfType:(MJWaterFlowViewMarginType)type{
    if ([self.delegate respondsToSelector:@selector(waterFlowView:marginForType:)]) {
        return [self.delegate waterFlowView:self marginForType:type];
    }else{
        return kWaterFlowViewDefaultCellMargin;
    }
}


#pragma mark - 点击事件
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self.delegate respondsToSelector:@selector(waterFlowView:didSelectAtIndex:)]) return;
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    __block NSNumber *selectedIndex = nil;
    //遍历当前显示的cell
    [self.displayingCell enumerateKeysAndObjectsUsingBlock:^(id key, MJWaterFlowCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, touchPoint)) {
            selectedIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectedIndex) {
        [self.delegate waterFlowView:self didSelectAtIndex:[selectedIndex integerValue]];
    }
    
}


@end
