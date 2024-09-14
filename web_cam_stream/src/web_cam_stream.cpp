#define _CRT_SECURE_NO_WARNINGS
//#define _USE_MATH_DEFINES

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
#include <windows.h>

#endif

// C/C++ includes
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <chrono>
#include <string>
#include <vector>
#include <algorithm>
#include <thread>

// OpenCV includes
#include <opencv2/core.hpp>           
#include <opencv2/highgui.hpp>     
#include <opencv2/imgproc.hpp> 
#include <opencv2/video.hpp>
#include <opencv2/imgcodecs.hpp>

// custom includes
//#include "ocv_threshold_functions.h"

// -------------------------------GLOBALS--------------------------------------

//-----------------------------------------------------------------------------
int main(int argc, char** argv)
{
    std::string sdate, stime;

    uint64_t idx=0, jdx=0;

    typedef std::chrono::nanoseconds ns;
    auto start_time = std::chrono::high_resolution_clock::now();
    auto stop_time = std::chrono::high_resolution_clock::now();
    double elapsed_time = std::chrono::duration_cast<ns>(stop_time - start_time).count();

    int bp = 0;

    try
    {

        //----------------------------------------------------------------------------------------
        // variables
        
        uint32_t img_h = 320;
        uint32_t img_w = 320;
        double fps = 30;
        int32_t four_cc = 0;

        double frame_time = 1.0e9 / fps;
        
        //std::vector<std::vector<cv::Point> > img_contours;
        //std::vector<cv::Vec4i> img_hr;

        //cv::Mat output_frame;
        cv::Mat input_frame;

        cv::RNG rng;

        cv::namedWindow("web_cam", cv::WINDOW_NORMAL);
        //cv::namedWindow("input", cv::WINDOW_NORMAL);

        //std::string cap_string = "rtsp://192.168.1.153:8554/camera-15";
//        cv::VideoCapture cap(cap_string);
        cv::VideoCapture cap(0);
        cap >> input_frame;

        img_h = input_frame.rows;
        img_w = input_frame.cols;

        std::string rtsp_stream;
        //rtsp_stream = "appsrc ! videoconvert ! video/x-raw, format=I420, format=BGR ! x264enc speed-preset=ultrafast key-int-max=60 ! video/x-h264, profile=baseline ! rtspclientsink protocols=tcp location=rtsp://192.168.1.150:8554/web_cam_stream";
        
        // fill the RTSP stream string with the correct values
        rtsp_stream = "appsrc ! videoconvert ! video/x-raw, format=I420 ! x264enc speed-preset=ultrafast key-int-max=60 ! video/x-h264, profile=baseline ! rtspclientsink protocols=tcp location=rtsp://127.0.0.1:8554/web_cam_stream";

        cv::VideoWriter writer(rtsp_stream, cv::CAP_GSTREAMER, four_cc, fps, cv::Size(img_w, img_h), true);

        if (writer.isOpened() == false)
            std::cout << std::endl << "could not open RTSP stream!" << std::endl << std::endl;

        std::cout << "Press \"q\" to quit" << std::endl;
        
        char key = 0;

        while (key != 'q')
        {
            start_time = std::chrono::high_resolution_clock::now();
            cap >> input_frame;

            if (input_frame.empty())
                continue;

            cv::imshow("web_cam", input_frame);

            writer << input_frame;

            key = cv::waitKey(1);

            // do
            // {
                // stop_time = std::chrono::high_resolution_clock::now();
                // elapsed_time = std::chrono::duration_cast<ns>(stop_time - start_time).count();
                ////std::cout << elapsed_time << std::endl;
            // } while (elapsed_time < frame_time);

        }

        //----------------------------------------------------------------------------------------

        bp = 4;

    }
    catch (std::exception &e)
    {
        std::cout << e.what() << std::endl;
    }

    cv::destroyAllWindows();

    //std::cout << std::endl << "Press Enter to close" << std::endl;
    //std::cin.ignore();

	return 0;

}	// end of main

