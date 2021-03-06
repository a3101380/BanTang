//
//  BTHomeViewController.m
//  BanTang
//
//  Created by User on 15/12/2.
//  Copyright © 2015年 LJ. All rights reserved.
//
#define EntryHeight (screenW - (4*10))/3.5 +20 
#define BannerHeight 230
#import "MJExtension.h"
#import "BTHomeViewController.h"
#import "BTTopic.h"
#import "BTEntry.h"
#import "BTBanner.h"
#import "BTTopicViewCell.h"
#import "BTEntryView.h"

@interface BTHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *topicArray;

@property(nonatomic,strong)NSMutableArray *entryArray;

@property(nonatomic,strong)NSMutableArray *bannerArray;

@property(nonatomic,strong)UITableView *topicTableView;

@property(nonatomic,strong)NSMutableArray *entryImageArray;

@property(nonatomic,strong)NSMutableArray *bannerImageArray;

@property(nonatomic,assign)NSInteger currentPage;

@property(nonatomic,assign)BOOL isUp;

@end

@implementation BTHomeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[BTHUDProgress shareHUD] showHUD:self.view];
    
    [self setUpDatasource:_currentPage];
    
    self.automaticallyAdjustsScrollViewInsets = false;
    
}


- (void)setUpDatasource:(NSInteger)page {
   
    [[BTHttpUtil shareHttpUtil] GET:[requestURL stringByAppendingString:@"recommend/index"] parameters:@{ @"page":[NSString stringWithFormat:@"%zd",page] , @"pagesize":[NSString stringWithFormat:@"%zd",PAGESIZE] } success:^(id responseObject) {
       
        NSMutableArray *topDic = [BTTopic mj_objectArrayWithKeyValuesArray:responseObject[@"topic"]];
        
        if(!_topicTableView){
            
            self.topicArray = topDic;
            
            self.entryArray = [BTEntry mj_objectArrayWithKeyValuesArray:responseObject[@"entry_list"]];
            
            self.bannerArray = [BTBanner  mj_objectArrayWithKeyValuesArray:responseObject[@"banner"]];
            
            [[BTHUDProgress shareHUD] hideHUD:self.view];
            
        }else if(_isUp){
            
            _topicArray = topDic;
            
            [_topicTableView.mj_header endRefreshing];
            
        }else{
            
            [_topicArray addObjectsFromArray:topDic];
            
            [_topicTableView.mj_footer endRefreshing];
            
        }
        
        [self.topicTableView reloadData];
        
    } failure:^(id responseObject) {
        
        
    }];
    
}
#pragma mark - table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.topicArray.count + 2;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        
        BTEntryView *bannerView = [[BTEntryView alloc] initWithFrame:CGRectMake(0, 0,screenW, BannerHeight)];
        
        bannerView.isPage = true;
        
        bannerView.height = BannerHeight;
        
        bannerView.entryArray = self.bannerImageArray;
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"banner"];
        
        [cell addSubview:bannerView];
        
        return cell;
        
    }else if(indexPath.row == 1){
        
        BTEntryView *entryView = [[BTEntryView alloc] initWithFrame:CGRectMake(0, 0,screenW, EntryHeight)];
        
        entryView.rowCount = 3.5;
        
        entryView.spaceWidth = 10;
        
        entryView.entryArray = self.entryImageArray;
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"entry"];
        
        [cell addSubview:entryView];
        
        return cell;
        
    }else{
        
        BTTopicViewCell *topicCell = [tableView dequeueReusableCellWithIdentifier:@"topicCell"];
        
        topicCell.topic = _topicArray[indexPath.row-2];
        
        return topicCell;
        
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 0){
        
        return 250;
        
    }else if(indexPath.row == 1){
        
        return EntryHeight;
        
    }
    
    return  270;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BTTopic *topic = self.topicArray[indexPath.row-2];
    
    NSLog(@"---%zd",topic.id);
    
}

#pragma mark - lazy loading
- (NSMutableArray *)topicArray{
    
    if(!_topicArray){
        
        _topicArray = [NSMutableArray array];
        
    }
    
    return _topicArray;
}

-(void)setBannerArray:(NSMutableArray *)bannerArray{
    
    if(!_bannerArray){
        
        _bannerArray = [NSMutableArray array];
        
    }

    _bannerArray = bannerArray;
    
    if(!_bannerImageArray){
        
        _bannerImageArray =[NSMutableArray array];
        
        for (BTBanner *banner in bannerArray) {
            
            [_bannerImageArray addObject:banner.photo];
            
        }
    }
    
}


- (void)setEntryArray:(NSMutableArray *)entryArray{
    
    if(!_entryArray){
        
        _entryArray = [NSMutableArray array];
        
    }
    
    _entryArray = entryArray;
    
    if(!_entryImageArray){
        
        _entryImageArray =[NSMutableArray array];
        
        for (BTEntry *entry in entryArray) {
            
            [_entryImageArray addObject:entry.pic1];
            
        }
    }
}

- (UITableView *)topicTableView{
    
    if(!_topicTableView){
        
        _topicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenW, screenH - tarBarButtom)];
        
        _topicTableView.delegate = self;
        
        _topicTableView.dataSource = self;
        
        [_topicTableView registerNib:[UINib nibWithNibName:NSStringFromClass([BTTopicViewCell class]) bundle:nil] forCellReuseIdentifier:@"topicCell"];
        
        _topicTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            [_topicArray removeAllObjects];
            
            _isUp = true;
            
            _currentPage = 0;
            
            [self setUpDatasource:_currentPage];
            
        }];
        
        _topicTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
           
            _isUp = false;
            
            _currentPage ++;
            
            [self setUpDatasource:_currentPage];
            
        }];

        [self.view addSubview:_topicTableView];
        
    }
    
    return _topicTableView;
}

@end
