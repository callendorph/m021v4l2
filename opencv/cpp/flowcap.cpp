/*
   flowcap.cpp - Simple demo of OpenCV image capture + optical flow using Leopard Imageing M021 camear on Linux.
  
   Copyright (C) 2016 Simon D. Levy

   This file is part of M021_V4L2.

   M021_V4L2 is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.
   BreezySTM32 is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with M021_V4L2.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <stdio.h>
#include <iostream>

#include <opencv2/opencv.hpp>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace cv;
using namespace std;

void drawOptFlowMap (const Mat& flow, Mat& cflowmap, int step, const Scalar& color) {
 for(int y = 0; y < cflowmap.rows; y += step)
        for(int x = 0; x < cflowmap.cols; x += step)
        {
            const Point2f& fxy = flow.at< Point2f>(y, x);
            line(cflowmap, Point(x,y), Point(cvRound(x+fxy.x), cvRound(y+fxy.y)),
                 color);
            circle(cflowmap, Point(cvRound(x+fxy.x), cvRound(y+fxy.y)), 1, color, -1);
        }
    }


int main()
{
    Mat img;
    Mat prev, next; 

    VideoCapture cap(0); 

    static const int SCALEDOWN = 1;

    while (true) {   

        cap >> img;

        resize(img, next, Size(img.size().width>>SCALEDOWN, img.size().height>>SCALEDOWN) );

        cvtColor(next, next, CV_BGR2GRAY);

        if (prev.data) {

            Mat flow;
            calcOpticalFlowFarneback(prev, next, flow, 0.5, 3, 15, 3, 5, 1.2, 0);

            drawOptFlowMap(flow, next, 10, CV_RGB(0, 255, 0));
        }

        imshow("Optical Flow", next);

        if (waitKey(5) >= 0)   
            break;

        prev = next;
    }
}



