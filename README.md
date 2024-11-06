# ![cube_globe_icon](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/cube_globe_icon.png)   Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving 
This project originated as my bachelor's thesis in Media Science and Technologies. 
It explores a different approach to matchmoving that bypasses traditional tracking techniques by integrating CGI models into footage, using Google Earth Studio (GES) data.
Rather than relying on tracking, camera calibration is achieved using geographic coordinates expressed in latitude, longitude, and altitude, provided by GES.
By converting these coordinates from ECEF to ENU and designing a custom Python script, camera's position, orientation, movement and properties can be accurately reconstructed in Maya, enabling seamless integration of CGI elements into the original footage.

## Workflow
The workflow proposed in this work utilizes Google Earth Studio (GES) data for a non-tracking-based matchmoving approach. Starting with GES, key camera data is extracted and processed in Matlab, frame by frame, in order to convert geographic coordinates (latitude, longitude, and altitude) from ECEF to ENU format, which is more compatible with Maya. A custom-designed Python script then uses this ENU information, saved in a JSON file, to reconstruct the camera animation in Maya, enabling accurate camera positioning, orientation, movement, and properties frame by frame. This procedure allows for the seamless integration of CGI elements into the processed footage.

![Project Workflow](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/workflow_00.svg)

## Results
The approach successfully bypasses traditional tracking methods, achieving CGI integration by relying on geographic data. Test cases showed smooth alignment of CGI elements within scenes, producing accurate spatial matching without the need for tracking markers. Below are some examples: 
- on the left, a frame from the original footage created in GES;
- on the right, a frame from the processed footage with integrated CGI elements.

### Fiumicino
![Fiumicino_original_footage]() ![Fiumicino_final_footage]()

### Stadium
![stadium_original_footage]() ![stadium_final_footage]()

