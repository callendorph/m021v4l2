#include "m021_v4l2.h"
#include "m021_opencv.hpp"

#include <stdio.h>

static pthread_t video_thread;
static pthread_mutex_t lock;
static int count;

static void * loop(void * arg)
{
    m021_800x460_t cap;
    m021_800x460_init(0, &cap);

    Mat * mat = (Mat *)arg;

    while (true) {

        pthread_mutex_lock(&lock);

        m021_800x460_grab_bgr(&cap, mat->data);

        pthread_mutex_unlock(&lock);

        count++;
    }

    return (void *)0;
}

void m021_800x460_capture(Mat & mat)
{
    mat = Mat(460, 800, CV_8UC3);

    if (pthread_mutex_init(&lock, NULL) != 0) {
        printf("\n mutex init failed\n");
        exit(1);
    }

    if (pthread_create(&video_thread, NULL, loop, &mat)) {
        fprintf(stderr, "Failed to create thread\n");
        exit(1);
    }
}

int m021_800x460_getcount(void)
{
    return count;
}


M021_800x460_Capture::M021_800x460_Capture(Mat & mat) {

    mat = Mat(460, 800, CV_8UC3);

    this->count = 0;

    if (pthread_mutex_init(&lock, NULL) != 0) {
        printf("\n mutex init failed\n");
        exit(1);
    }

    if (pthread_create(&video_thread, NULL, loop, &mat)) {
        fprintf(stderr, "Failed to create thread\n");
        exit(1);
    }
}
        
int M021_800x460_Capture::getCount(void) {

    return this->count;
}
