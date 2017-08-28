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

@interface ViewController () <ARSCNViewDelegate,ARSessionDelegate>
//AR视图:展示3D 界面
@property (strong, nonatomic) ARSCNView       *arSceneView;
//AR会话: 负责管理相机最终的配置及3D 相机坐标
@property (nonatomic, strong) ARSession       *session;
//会话配置: 负责追踪配置相机的运动
@property (nonatomic, strong) ARConfiguration *sessionConfig;

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

- (ARConfiguration *)sessionConfig{
    if (_sessionConfig != nil) {
        return _sessionConfig;
    }
    
    //1. 创建世界追踪坐标配置
    ARWorldTrackingConfiguration *config = [[ARWorldTrackingConfiguration alloc] init];
    //2. 设置追踪方向(追踪平面)
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
    
    _session.delegate = self;
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
    
    // 4. 设置代理 捕捉到平地会在代理回调中返回
    _arSceneView.delegate = self;
    return _arSceneView;
}


#pragma mark - 添加一个场景
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    //1. 使用场景加载 scn 文件
//
//    SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/vase/vase.scn"];
//    SCNNode *plantNode = scene.rootNode.childNodes[0];
//
//    //调整位置 将节点添加到当前屏幕中
//    plantNode.position = SCNVector3Make(0, -1, -1);
//
//
//    //将飞机节点添加到当前屏幕
//    [self.arSceneView.scene.rootNode addChildNode:plantNode];
//
//}

#pragma mark -
#pragma mark - ARSCNViewDelegate 代理
- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    
    if ([anchor isMemberOfClass:[ARPlaneAnchor class]]) {
        NSLog(@"捕捉到平地");
        //添加一个3D 平面模型,ARKit 只有捕捉能力,锚点是一个空间位置,要想更加清楚的看到这个空间,我们需要给空间添加一个平地的3D模型来渲染他
        //1. 获取扑捉到的平地锚点
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        //2. 创建一个3D物体模型 (系统捕捉到的平地是一个不规则大小的长方形，这里我们将其变成一个长方形，并且对平地做一次缩放）
        //创建长方形  参数:长,宽,高,圆角
        SCNBox *plane = [SCNBox boxWithWidth:planeAnchor.extent.x * 0.3 height:0 length:planeAnchor.extent.x * 0.3 chamferRadius:0];
        //3. 使用Material渲染3D模型 默认模型是白色的
        plane.firstMaterial.diffuse.contents = [UIColor cyanColor];
        
        //4. 创建一个基于3D 物体模型的节点
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        //5. 设置节点的位置为捕捉到的平地的锚点和中心位置 SceneKit框架中节点的位置position是一个基于3D坐标系的矢量坐标SCNVector3Make
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        
        [node addChildNode:planeNode];
        
        //6. 当捕捉到平地时，2s之后开始在平地上添加一个3D模型
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //1.创建一个花瓶场景
            SCNScene *scene = [SCNScene sceneNamed:@"Models.scnassets/vase/vase.scn"];
            //2.获取花瓶节点（一个场景会有多个节点，此处我们只写，花瓶节点则默认是场景子节点的第一个）
            //所有的场景有且只有一个根节点，其他所有节点都是根节点的子节点
            SCNNode *vaseNode = scene.rootNode.childNodes[0];
            
            //4.设置花瓶节点的位置为捕捉到的平地的位置，如果不设置，则默认为原点位置，也就是相机位置
            vaseNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
            
            //5.将花瓶节点添加到当前屏幕中
            //!!!此处一定要注意：花瓶节点是添加到代理捕捉到的节点中，而不是AR试图的根节点。因为捕捉到的平地锚点是一个本地坐标系，而不是世界坐标系
            [node addChildNode:vaseNode];
        });
        
        
    }
}


//刷新时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"刷新中");
}

//更新节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点更新");
    
}

//移除节点时调用
- (void)renderer:(id <SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"节点移除");
}

#pragma mark -ARSessionDelegate

//会话位置更新（监听相机的移动），此代理方法会调用非常频繁，只要相机移动就会调用，如果相机移动过快，会有一定的误差，具体的需要强大的算法去优化，笔者这里就不深入了
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    NSLog(@"相机移动");
    
}
- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"添加锚点");
    
}


- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"刷新锚点");
    
}


- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor*>*)anchors
{
    NSLog(@"移除锚点");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
