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
![Fiumicino_original_footage](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/Fiumicino_img.png) ![Fiumicino_final_footage](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/Fiumicino_Final_img.png)

### Stadium
![stadium_original_footage](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/Stadium_img.png)   ![stadium_final_footage](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/blob/main/images/Stadium_Final_img.png)

## Future Developments
Potential improvements include refining the camera calibration presented in this work for more accurate animation in Maya and simplifying the procedure for deriving Pan, Tilt, and Roll angles, as the solution proposed in this thesis is somewhat complex and cumbersome. Additionally, expanding this procedure to live-action footage and improving compatibility with other 3D software andcould be possible, while AI-driven adjustments may further enhance CGI realism and streamline the workflow.

## Content
- The thesis produced for this work is avaible in [thesis.pdf](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/tree/main/thesis). Currently, this file is written in Italian, but an English version will be uploaded as soon as possible.
- Regarding the implementation, MATLAB and Python scripts, along with the related JSON file, are available in the [code](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/tree/main/code) folder.
- some examples of the original footage and its final version are avaible in the [renders](https://github.com/FedericoCGI/Integration-in-the-Google-Earth-Studio-Environment-for-Non-Tracking-Based-Matchmoving/tree/main/renders) folder.

## Autor
[Federico March](https://github.com/FedericoCGI)

## Technologies
For this work, the following technologies were used:
- Google Earth Studio (GES): As the primary source of geographic camera data and for generating the original footage.
- JSON: To store and transfer processed data between applications.
- MATLAB: For data processing and coordinate conversion (ECEF to ENU).
- Python: To develop custom scripts for camera properties and animation reconstruction.
- Maya: For 3D modeling and CGI integration.
- Maya Software: For batch render. 

