# Code Guidelines:

Camera key data were exported from Google Earth Studio (GES) in a JSON file format (Fiumicino 5 .json) for the Fiumicino scene.

This file was processed in Matlab in order to convert goegrafic coordinates (letitude, longitude and altitude) from ECEF to ENU, derive the Pan, Tilt and Roll angles for camera orintation and calculate camera properties like focal lenght, based on GES data provided frame by frame. 

Matlab code and original JSON file exported from GES are avaible in [Matlab](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/tree/main/code/Matlab) folder.

To reconstruct camera properties and animation in Maya, MATLAB information must be stored in a new JSON file and then used in a Python script, run in Maya. This script helps to automate the camera settings and animation process, frame by frame.

Python code and JSON file containing Matlab information (Fiumicino Animation.json) are avaible in [Python](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/tree/main/code/Python) folder.
