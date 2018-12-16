# Locomolyzer

## Description
This is a tool for tracking and analyzing locomotion of animals in 2D. It was mainly designed for locomotion analysis of *C. elegans* worms. 

It was presented at the [European Society for Biomechanics congress 2015](https://www.czech-in.org/cm/ESB/CM.NET.WebUI/CM.NET.WEBUI.scpr/SCPRsessions.aspx?conferenceid=05000000-0000-0000-0000-000000000056&sessionId=05000000-0000-0000-0000-000000003679)

It is currently still under development so it still has quite some bugs and some limitations.

## Limitations
- Input image can only be 512x512 (to be fixed soon)
- Still need to update the algorithm to accommodate for different types of image sequences

## Dependencies
It only depends on the external function [SegCroissRegion](https://www.mathworks.com/matlabcentral/fileexchange/35269-simple-single-seeded-region-growing?focused=5229193&tab=function). It is included in the code for convenience.
Some code snippets were imported from [Track-A-Worm, An Open-Source System for Quantitative Assessment of C. elegans Locomotory and Bending Behavior](https://doi.org/10.1371/journal.pone.0069653).

## Algorithm
I used a region growing algorithm where the first seed is inserted manually by user while the next seeds are predicted using a Kalman filter-like approach.
![Alt text](algorithm.jpg?raw=true)

## Usage
Sample data can be found [here](https://figshare.com/articles/C_elegans_SampleVideo/7471382). This file can be downloaded and added to the folder data.
Then you can open Locomolyzer and load the file. Then you can press skeletonize and make the first spline (9 or more points), then adjust the threshold, strel size, x and y calibration.

Pressing Done after, will let the code go independently.
![Alt text](screenshot.jpg?raw=true)


## Output
three files will be generated, one for midline skeleton and one for each of the ventral and dorsal edges.
