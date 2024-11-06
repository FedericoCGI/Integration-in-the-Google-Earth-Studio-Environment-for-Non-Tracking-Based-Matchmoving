# -*- coding: utf-8 -*-

#questo è il codice dello script che legge i dati di un file JSON in cui sono contenuti i dati di GES elaborati in Matlab ed esportati in un nuovo file JSON per essere importati in Maya tramite Python

#script per la traslazione e rotazione della camera

#importiamo i dati dal file JSON generato in Matlab



import json
import maya.cmds as cmds
with open('C:\\Users\\PythonEnv\\MayaScript\\Fiumicino Animation.json',"r") as f:
    data = json.load(f)
camera=data['Frames']




#realizziamo la funzione/script per animare i frame con i dati relativi alla posizione pos passati dal file JSON per il frame i dato

def setKeyFrame(pos,rot,cam,i):#define function for setting the clip keyframes
    objs=cmds.ls(selection=True)#retrieve the Maya selected object
    obj=objs[0]

    #current frame
    frm=i

    #object position
    xVal=pos['x']
    yVal=pos['y']
    zVal=pos['z']

    #object rotation
    

    pan=-360+rot['pan']#in Maya dobbiamo  cambiare il segno all'angolo di pan per ottenere lo stesso valore di pan di GES
    tilt=-90+rot['tilt']#vogliamo che la camera guardi perpendicolarmente verso il basso quando tilt=0, che in maya corrisponde ad un tilt di -90
    roll=rot['roll']#in Maya dobbiamo cambiare il segno all'angolo di roll per ottenere lo stesso valore di roll di GES roll di GES
    
        
    
    
    #set keyframes and translate the object in space
    cmds.setKeyframe(obj + '.translateX', value=xVal, time=frm)#when we set a keyframe we need the object name and attribute , the time at wich to set keyframe, the value to set the attribute to
    cmds.setKeyframe(obj + '.translateY', value=yVal, time=frm)
    cmds.setKeyframe(obj + '.translateZ', value=zVal, time=frm)

    #set keyframes and rotate the object in space
    cmds.setKeyframe(obj + '.rotateX', value=tilt, time=frm)
    cmds.setKeyframe(obj + '.rotateY', value=pan, time=frm)
    cmds.setKeyframe(obj + '.rotateZ', value=roll, time=frm)

    #set keyframes and set Horizonatl Film Aperture of the camera, converting mm horizontal Aperture to inches one
    cmds.setKeyframe(obj + '.horizontalFilmAperture', value=cam['sensore']['horizontal']*0.0393701, time=frm)
    
    #set keyframes and set Vertical Film Aperture of the camera, converting mm vertical Aperture to inches one
    cmds.setKeyframe(obj + '.verticalFilmAperture', value=cam['sensore']['vertical']*0.0393701, time=frm)

    
    #set keyframes and set Focal Length of the camera
    cmds.setKeyframe(obj + '.focalLength', value=cam['focale'], time=frm)

    #set keyframes and set FOV Horizontal of the camera
    #cmds.setKeyframe(obj + '.horizontalFieldOfView', value=cam['fovH'], time=frm)

    

    

#estraiamo i dati dal file JSON e animiamo la camera con i dati, usando per ogni frame la funzione setKeyFrame
for f in camera:#LOOP FRAME SCRIPT -->for each frame in the clip
    frame=f['frame']
    pos=f['position']
    rot=f['rotation']
    cam={}#creo un dizionarario che ospiterà i dati di setting della camera in Maya
    
    cam['sensore']=f['sensore']
    cam['fovH']=f['fov']['horizontal']
    cam['focale']=f['focale']#28.000

    
    setKeyFrame(pos,rot,cam,frame)




#Ora, dopo aver selezionato la camera in Maya e lanciato in run questo script, si deve selezionare il camera aim e lanciare in run lo script GES_Aim_to_Maya

#comando per eseguire un'istruzione della mel che ccrea un cubo
#mel.eval("polyCube -ch on -o on -w ",d," -h ",d," -d ",d," -sw 5 -sd 5 -cuv 4")

#comando mel per creare una camera
#camera -centerOfInterest 5 -focalLength 35 -lensSqueezeRatio 1 -cameraScale 1 -horizontalFilmAperture 1.41732 -horizontalFilmOffset 0 -verticalFilmAperture 0.94488 -verticalFilmOffset 0 -filmFit Fill -overscan 1 -motionBlur 0 -shutterAngle 144 -nearClipPlane 0.1 -farClipPlane 10000 -orthographic 0 -orthographicWidth 30 -panZoomEnabled 0 -horizontalPan 0 -verticalPan 0 -zoom 1; objectMoveCommand; cameraMakeNode 2 "";
 


