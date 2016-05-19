//
//  ViewController.m
//  NSNullHandler
//
//  Created by Mike on 5/19/16.
//  Copyright © 2016 Mike. All rights reserved.
//

#import "ViewController.h"

#import "ZHSomeModel.h"
#import "JSONKit.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSString *strJson = @"[{\"Id\": 1,\"BrandName\": null},{\"Id\": 2,\"BrandName\": \"Mike\"}]";
    NSArray *arrlist=[strJson objectFromJSONString];
    NSLog(@"%lu",[arrlist count]);
    
    NSMutableArray *tempArray = [NSMutableArray array];
    for (int i=0; i<[arrlist count]; i++) {
        
        NSDictionary *item=[arrlist objectAtIndex:i];
        ;
        NSLog(@"the length of the value in the dictionary:%lu",[[item objectForKey:@"BrandName"] length]);
        
        ZHSomeModel *someModel = [[ZHSomeModel alloc]init];
        someModel.Id = [item[@"Id"] integerValue];
        someModel.BrandName = item[@"BrandName"];
        
        [tempArray addObject:someModel];
        
    }
    
    for ( ZHSomeModel *someModel in tempArray) {
        
        NSLog(@"the length of the BrandName of the Model:%lu",[someModel.BrandName length]);
        
    }
    
    
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
