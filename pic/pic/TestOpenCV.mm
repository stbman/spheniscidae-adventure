//
//  TestOpenCV.m
//  pic
//
//  Created by Adrian Lim on 25/8/15.
//  Copyright © 2015 Adrian Lim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "pic-Bridging-Header.h"

#import <opencv2/opencv.hpp>
#import <opencv2/highgui/ios.h>

@implementation TestOpenCV : NSObject

+(UIImage *)DetectEdgeWithImage:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::Mat gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    
    cv::Mat edge;
    cv::Canny(gray, edge, 200, 100);

    
    UIImage *edgeImg = MatToUIImage(edge);
    return edgeImg;
}

@end