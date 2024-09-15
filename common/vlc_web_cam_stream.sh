#!/bin/bash

# example script that starts up a VLC instance and streams the webcam to an RTSP server
cvlc -v v4l2:///dev/video0 --sout '#transcode{vcodec=h264,vb=600,acodec=none}:rtp{sdp=rtsp://192.168.1.24:8554/web_cam_stream}'
