//
//  MainViewController.h
//  ARreal
//
//  Created by zhangjiajia on 13-5-16.
//  Copyright (c) 2013年 bravesoft. All rights reserved.
//

#import "MetaioSDKViewController.h"

@interface MainViewController : MetaioSDKViewController
{
    metaio::IGeometry*       m_imagePlane;           // pointer to the image plane
    metaio::IGeometry*       m_metaioMan;            // pointer to the metaio man model
    metaio::IGeometry*       m_moviePlane;           // pointer to our movie plane
    metaio::IGeometry*       m_truck;
}

@property (retain) UIToolbar *_toolbar;
@end
