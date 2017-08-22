//
//  ViewController.m
//  ARDemo
//
//  Created by sunyazhou on 2017/8/11.
//  Copyright © 2017年 Kingsoft, Inc. All rights reserved.
//

#import "ViewController.h"

//3D 游戏框架
#import <SceneKit/SceneKit.h>

#import <ARKit/ARKit.h>

@interface ViewController () <ARSCNViewDelegate>
//AR视图:展示3D 界面
@property (strong, nonatomic)  ARSCNView *arSceneView;
//AR会话: 负责管理相机最终的配置及3D 相机坐标
@property (nonatomic, strong) ARSession *session;

//会话配置: 负责追踪配置相机的运动
@property (nonatomic, strong) ARSessionConfiguration *sessionConfig;

//飞机3D 模型
@property (nonatomic, strong) SCNNode *planeNode;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //1. 将 AR 视图添加到当前的视图
    [self.view addSubview:self.arSceneView];
    
    //2. 开启 AR 会话(这个时候相机开始工作)
    [self.session runWithConfiguration:self.sessionConfig];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.arSceneView.session pause];
}

#pragma mark -
#pragma mark - 创建步骤

- (ARSessionConfiguration *)sessionConfig{
    if (_sessionConfig != nil) {
        return _sessionConfig;
    }
    
    //1. 创建世界追踪坐标配置
    ARWorldTrackingSessionConfiguration *config = [[ARWorldTrackingSessionConfiguration alloc] init];
    //2. 设置追踪方向(追踪平面,后面会讲到)
    config.planeDetection = ARPlaneDetectionHorizontal;
    _sessionConfig = config;
    //3. 自适应灯光
    _sessionConfig.lightEstimationEnabled = YES;
    
    return _sessionConfig;
}

//创建会话
- (ARSession *)session{
    if (_session != nil) { return _session; }
    
    //1.创建会话
    _session = [[ARSession alloc] init];
    //2.返回
    return _session;
}

//创建 AR 视图
- (ARSCNView *)arSceneView{
    if (_arSceneView != nil) { return _arSceneView; }
    // 1. 创建 AR视图
    _arSceneView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    // 2. 设置视图会话
    _arSceneView.session = self.session;
    // 3. 自动刷新灯光(3D游戏里会用到)
    _arSceneView.automaticallyUpdatesLighting = YES;
    return _arSceneView;
}


#pragma mark - 添加一个场景
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //1. 使用场景加载 scn 文件
    
    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/vase/vase.scn"];
    SCNNode *plantNode = scene.rootNode.childNodes[0];
    
    //调整位置
    plantNode.position = SCNVector3Make(0, -1, -1);
    
    
    //将飞机节点添加到当前屏幕
    [self.arSceneView.scene.rootNode addChildNode:plantNode];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
