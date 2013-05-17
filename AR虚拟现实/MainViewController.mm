//
//  MainViewController.m
//  ARreal
//
//  Created by zhangjiajia on 13-5-16.
//  Copyright (c) 2013年 bravesoft. All rights reserved.
//
//  metaio SDK
//
//  Copyright metaio, GmbH 2012. All rights reserved.
//
#import "MainViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface MainViewController ()
- (void) setActiveModel: (int) modelIndex;
@end

@implementation MainViewController
@synthesize _toolbar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - UIViewController lifecycle

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    _toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-44-20, 320, 44)];
    _toolbar.userInteractionEnabled = YES;
    UIBarButtonItem *changeCamera = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(takePicture:)];
    
    UIBarButtonItem *barBtnRightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(switchFace:)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *toolbarButtons = [[NSArray alloc] initWithObjects:changeCamera, flexSpace, barBtnRightButton, nil];

    _toolbar.items = toolbarButtons;
    [self.view addSubview:_toolbar];
    
    // load our tracking configuration
    // 取出跟踪目标
    NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_MarkerlessFast" ofType:@"xml" inDirectory:@"Assets2"];
    
    // if you want to test the 3D tracking, please uncomment the line below and comment the line above
    //NSString* trackingDataFile = [[NSBundle mainBundle] pathForResource:@"TrackingData_ML3D" ofType:@"xml" inDirectory:@"Assets"];
    
    //设定跟踪目标
	if(trackingDataFile)
	{
		bool success = m_metaioSDK->setTrackingConfiguration([trackingDataFile UTF8String]);
		if( !success)
			NSLog(@"No success loading the tracking configuration");
	}
    
    
    
    // load content
    NSString* modelPath = [[NSBundle mainBundle] pathForResource:@"metaioman" ofType:@"md2" inDirectory:@"Assets2"];
    
	if(modelPath)
	{
		// if this call was successful, theLoadedModel will contain a pointer to the 3D model
        m_metaioMan =  m_metaioSDK->createGeometry([modelPath UTF8String]);
        if( m_metaioMan )
        {
            // scale it a bit up
            m_metaioMan->setScale(metaio::Vector3d(4.0,4.0,4.0));
        }
        else
        {
            NSLog(@"error, could not load %@", modelPath);
        }
    }
    
    
    // loadimage
    
    NSString* imagePath = [[NSBundle mainBundle] pathForResource:@"frame" ofType:@"png" inDirectory:@"Assets2"];
    
    if (imagePath)
    {
        m_imagePlane = m_metaioSDK->createGeometryFromImage([imagePath UTF8String]);
        if (m_imagePlane) {
            m_imagePlane->setScale(metaio::Vector3d(3.0,3.0,3.0));
        }
        else NSLog(@"Error: could not load image plane");
    }
    
    // load the movie plane
    NSString* moviePath = [[NSBundle mainBundle] pathForResource:@"demo_movie" ofType:@"3g2" inDirectory:@"Assets2"];
    
	if(moviePath)
	{
        m_moviePlane =  m_metaioSDK->createGeometryFromMovie([moviePath UTF8String], true); // true for transparent movie
        if( m_moviePlane)
        {
            m_moviePlane->setScale(metaio::Vector3d(2.0,2.0,2.0));
            m_moviePlane->setRotation(metaio::Rotation(metaio::Vector3d(0, 0, -M_PI_2)));
            
        }
        else
        {
            NSLog(@"Error: could not load movie planes");
        }
    }
    
    //load the truck model
    NSString* truckPath = [[NSBundle mainBundle] pathForResource:@"truck" ofType:@"obj" inDirectory:@"Assets2/truck"];
    
    if (truckPath)
    {
        m_truck = m_metaioSDK->createGeometry([truckPath UTF8String]);
        if (m_truck)
        {
            m_truck->setScale(metaio::Vector3d(2.0, 2.0, 2.0));
            m_truck->setRotation(metaio::Rotation(metaio::Vector3d(M_PI_2, 0, M_PI)));
        }
        else {
            NSLog(@"Error: could not load truck model");
        }
    }
    
    //load env_map
    NSString* mapPath = [[NSBundle mainBundle] pathForResource: @"env_map" ofType:@"" inDirectory:@"Assets2"];
    
    if (mapPath)
    {
        Boolean loaded = m_metaioSDK->loadEnvironmentMap([mapPath UTF8String]);
        NSLog(@"The environment maps have been loaded: %d", (int)loaded);
        
    }
    else
    {
        NSLog(@"Error: The filepath for the environment maps is invalid");
    }
    
    
    
    // start with metaio man
    [self setActiveModel:1];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}



- (void) viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [super viewDidUnload];
}


#pragma mark - App Logic
- (void) setActiveModel: (int) modelIndex
{
    switch ( modelIndex )
    {
        case 0:
        {
            m_imagePlane->setVisible(false);
            m_metaioMan->setVisible(true);
            m_truck->setVisible(false);
            
            // stop the movie
            m_moviePlane->setVisible(false);
            m_moviePlane->stopMovieTexture();
        }
            break;
            
            
        case 1:
            m_imagePlane->setVisible(true);
            m_metaioMan->setVisible(false);
            m_truck->setVisible(false);
            
            // stop the movie
            m_moviePlane->setVisible(false);
            m_moviePlane->stopMovieTexture();
            break;
            
        case 2:
            m_imagePlane->setVisible(false);
            m_metaioMan->setVisible(false);
            m_truck->setVisible(true);
            
            m_moviePlane->setVisible(false);
            m_moviePlane->stopMovieTexture();
            break;
            
            
        case 3:
            m_imagePlane->setVisible(false);
            m_metaioMan->setVisible(false);
            m_truck->setVisible(false);
            
            m_moviePlane->setVisible(true);
            m_moviePlane->startMovieTexture(true); // loop = true
            break;
    }
    
}

- (IBAction)onSegmentControlChanged:(UISegmentedControl*)sender
{
    [self setActiveModel:sender.selectedSegmentIndex];
}

- (IBAction)onButtonpressed:(id)sender
{
    
}


- (void)takePicture:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	
    // the path to write file
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:@"myFile.jpg"];
    NSError * error;
    if([[NSFileManager defaultManager]fileExistsAtPath:filepath])
        [[NSFileManager defaultManager]removeItemAtPath:filepath error:&error];
    NSLog(@"filepath %@",filepath);
    m_metaioSDK -> requestCameraImage([filepath UTF8String], 320, 480); // 保存照片
//    m_metaioSDK -> requestScreenshot([filepath UTF8String]);
  
}

#pragma mark - Rotation handling


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    // allow rotation in all directions
    return YES;
}


@end
