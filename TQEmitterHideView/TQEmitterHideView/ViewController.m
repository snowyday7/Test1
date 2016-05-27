//
//  ViewController.m
//  TQEmitterHideView
//
//  Created by xtq on 15/9/17.
//  Copyright (c) 2015年 one. All rights reserved.
//

#import "ViewController.h"
#import "TQEmitterHideUtil.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *tableView;

@end

@implementation ViewController
{
    NSMutableArray *_dataArray;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        //eretrtererer
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    
    _dataArray = [[NSMutableArray alloc]init];
    for (NSInteger i = 0; i < 20; i++) {
        [_dataArray addObject:[NSString stringWithFormat:@"cellForRowAtIndexPath %ld",i]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    }

static NSInteger count = 0;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    TQEmitterHideDirection direction = 0;
    switch (count % 4) {
        case 0:
            direction = TQEmitterHideDirectionLeft;
            break;
        case 1:
            direction = TQEmitterHideDirectionRight;
            break;
        case 2:
            direction = TQEmitterHideDirectionBottom;
            break;
        case 3:
            direction = TQEmitterHideDirectionTop;
            break;
        default:
            break;
    }
    
    TQEmitterHideUtil *util2 = [[TQEmitterHideUtil alloc]init];
    [util2 hideView:cell duration:1 direction:direction completion:^(BOOL finished) {
        NSMutableArray *muArr = [[NSMutableArray alloc]init];
        [muArr addObject:indexPath];
        [_dataArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:muArr withRowAnimation:UITableViewRowAnimationFade];
    }];
    tableView.userInteractionEnabled = YES;
    count++;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (UITableView *)tableView {
    if (!_tableView) {
        CGRect frame = self.view.bounds;
        
        frame.origin.x += 50;
        frame.origin.y += 50;
        frame.size.width -= 100;
        frame.size.height -= 100;

        _tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 80;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [[UIView alloc]init];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
