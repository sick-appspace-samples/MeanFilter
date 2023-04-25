## MeanFilter

Applying mean filter and echo filter on scans read from a file

### Description

This sample shows how to apply a mean filter and an echo filter to scans read
from file and displays the filtered scan as a point cloud. A file scan provider is
created and and the scans from the file are played back. The filtered scan is
shown in the PointCloud viewer on the web-page.
In addition, the noise is estimated as positive difference between the mean distances
and the distances of the last scan of a block.

### How To Run

Starting this sample is possible either by running the App (F5) or
debugging (F7+F10). Output is printed to the console and the transformed
point cloud can be seen on the viewer in the web page. The playback stops
after the last scan in the file. To replay, the sample must be restarted.
To run this sample, a device with AppEngine >= 2.5.0 is required.

### Implementation

To run with real device data, the file provider has to be exchanged with the
appropriate scan provider.

### Topics

algorithm, scan, filtering, sample, sick-appspace
