#!/usr/bin/env python3

'''
capture.py : capture frames from Leopard Imaging LI-USB30-M021 camera and display them using OpenCV

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
'''

import argparse
import cv2
from m021v4l2 import m021v4l
from time import time

def setup_options():
    parser = argparse.ArgumentParser(description="Test Script for Capturing Frames and Displaying them using opencv")

    parser.add_argument(
        "-d", "--device", default=0, type=int,
        help="Index of the video device that we will open to stream frames. The default is %(default)s."
    )
    parser.add_argument(
        "-w", "--width", default=800, type=int,
        help="Set the width of the frame in pixels we will capture from the camera. This value is dependent on the hardware of the camera we are connecting to. Default: %(default)s"
    )
    parser.add_argument(
        "-k", "--height", default=460, type=int,
        help="Set the height of the frame in pixels we will capture from the camera. This value is dependent on the hardware of the camera we are connecting to. Default: %(default)s"
    )

    parser.add_argument(
        "-c", "--color-corr", default = "0,0,0",
        help='Comma separate list of color corrections that will be applied to each of the pixels in the image frame. For negative values, use the "=" sign variant of the option. For Example: -c="-1,-3,-5".'
    )

    opts = parser.parse_args()

    if ( opts.device < 0 ):
        parser.error("Device Value can't be less than zero")

    if ( opts.width <= 0 or opts.height <= 0 ):
        parser.error("Frame Width/Height must be greater than zero")
    print("Device: {}".format(opts.device))
    print("Frame Dims: {}x{}".format(opts.width, opts.height))

    if ( opts.color_corr is not None and len(opts.color_corr) > 0 ):
        corrs = opts.color_corr.split(",")
        icorrs = [int(x) for x in corrs]
        if ( len(icorrs) != 3 ):
            parser.error("Color Corrections must be length 3 list")

        if ( any([ (x > 127 or x < -128) for x in icorrs ] ) ):
            parser.error("Color Correction values must int8_t type (-128 < x < 127)")
        print("Color Corrections: {}".format(icorrs))
        opts.color_corr = icorrs

    return(opts)

if ( __name__ == "__main__" ):

    opts = setup_options()
    bcorr, gcorr, rcorr = opts.color_corr
    cap = m021v4l(opts.device, opts.width, opts.height, bcorr, gcorr, rcorr)

    start = time()

    while True:

        # Capture frame-by-frame
        frame, ts = cap.read()

        # Display the resulting frame
        cv2.imshow('LI-USB30-M021',frame)
        if cv2.waitKey(1) & 0xFF == 27:
            break

    count = cap.get_count()
    elapsed = time() - start
    print('%d frames in %3.2f seconds = %3.2f fps' % (count, elapsed, count/elapsed))

    # When everything done, release the capture
    cv2.destroyAllWindows()
