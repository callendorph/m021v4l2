# M021V4L2: Capture images from Leopard Imaging LI-USB30-M021 camera on Linux in C++ and Python

The LI-USB30-M021 camera from Leopard Imaging is a fast (up to 90 frames per
second) global-shutter CMOS camera that captures images over USB 3.0.  Because the
camera serves up raw image bytes, getting it to work on Linux using V4L2 (Video
For Linux 2) requires a bit of extra format-conversion work.  With some help
from the folks at Leopard Imaging, I was able to write a few simple APIs for
the camera for people who want to use it on Linux without doing the conversion
themselves.

The C++ and Python APIs are intended for OpenCV users who want to be able to
capture images as a Mat object (C++) or NumPy array (Python). C++ code runs on its own thread. Python code is direct and not-thread safe. As the code fragment below shows, the classes are extremely simple to use:

<pre>
    import m021v4l2
    cap = m021v4l2.m021v4l(0,800,460,0,0,0)

    while True:

        frame, ts = cap.read()

        cv2.imshow('LI-USB30-M021',frame)

        if cv2.waitKey(1) & 0xFF == 27:
            break
 </pre>


The python module is built using cython and will run in Python 2 or 3. Dealer's choice.

Install the prerequisites:
<pre>
  % pip install numpy opencv-python cython
</pre>

Then run the build:
<pre>
  % cd opencv/python
  % python setup.py install
</pre>

Then make sure the device you want to use is read/write for your user
and run the capture program:

<pre>
  % sudo chmod a+rw /dev/device0
  % python capture.py -d 0 -w 800 -k 460
</pre>

To run the C++ OpenCV capture demo, cd to <b>opencv/cpp</b> and type <b>make
cap</b>.

Both of these programs do some post-capture color balancing to compensate for
the slightly dimmed / green appearance of the image from the camera. See the `python capture.py -h` for more info on setting the correction values.

I've also provided a C API (which is used by the C++ and Python code) for
capturing images in YUYV format, along with a demo program (a cut-down version
of Guvcview) that displays the images using GTK and SDL.  To run the GTK/SDL
demo, cd to <b>gtksdl</b> and type <b>make run</b>.

<b>Known Issues</b>

<ul>
<li> <del>Programs will occasionally seg-fault on exit.</del> Python is fixed - unsure about C++. The problem is due to the fact that the thread is not cleaned up on exit and the thread continues to try and access objects that have been freed.</li>
<p><li> On ODROID XU4, Python3 version is much slower than C++ version.
<p><li> On desktop Ubuntu 16.04, an <b>Unable to dequeue buffer</b> error
occurs in the OpenCV C++ examples, and no image is displayed.
</ul>
