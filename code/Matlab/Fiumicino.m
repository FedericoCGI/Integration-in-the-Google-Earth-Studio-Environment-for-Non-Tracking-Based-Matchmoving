%questo è lo script per leggere un file JSON, importare i dati, processarli
%e poi ricreare un nuovo file JSON

%Leggiamo il file JSON 
fname = 'Fiumicino 5.json'
fid = fopen(fname); 
raw = fread(fid); 
str = char(raw'); 
fclose(fid); 
val = jsondecode(str);

%costruiamo un modello spheroid- Terra che useremo per simulare la
%superficie sferica del pianeta Terra, ovvero una sfera di raggio 
%R=6371011.002127982, che corrisponderebbe al raggio medio terrestre

earth= referenceSphere; %create a spheroid object
earth.Name='Earth'; %set data member
earth.LengthUnit = 'meter';
earth.Radius=6371011;   %   Questo valore del raggio è una misura più precisa %6371011.002127982;%GES result
format long %display all radius value

%importiamo i dati per ogni frame

%dimensioni del frame
width=val.width;
height=val.height;

%numero di frames nella clip
numFrames=val.numFrames;


%ricaviamo l'origine locale del frame in ECEF
tp=val.trackPoints(1);%l'origine locale in GES viene impostata come un trackpoint.
origin=[tp.position.x, tp.position.y,tp.position.z]


%{
lat=41.93394952455;
lon=12.454778848626;
alt=0;

[xe,ye,ze]=geodetic2ecef(earth,lat,lon,alt)
%}

%trackpoints
xt=4628001.876032035;
yt=1022151.8330829913;
zt=4257532.786449218;

%{
A
xt=4627941.385418739;
yt=1022110.9780294693;
zt=4257608.347868686;

%}

%{
B
xt=4627915.000987416;
yt=1022172.2153699233;
zt=4257622.325651065;
%}

%{
C
xt=4627975.432410018;
yt=1022213.6422283065;
zt=4257546.691320324;


%}


%ricaviamo latitudine, longitudine e altitudine dell'origine. Ci
%serviranno questi dati, i seguito, per convertire le coordinate ECEF in
%ENU

[Clat,Clon,Calt]=ecef2geodetic(earth,origin(1),origin(2),origin(3));
%Google Earth Studio imposta Calt a 1, ma questo corrisponde nei calcoli ad
%un valore di Calt=0

%Costruiamo una matrice F, in cui vengono salvati dei dati relativi alla camera per ogni Frames.
%La matrice F è così strutturata: 
%le righe corrispondono ai frame di cui si compone la clip, mentre le
%colonne indicano i dati che abbiamo sulla camera per ogni frame. 
%Le colonne possono dividersi in 4 gruppi:
%se indichiamo con i la iesima riga, ovvero il frame iesimo,
%   GRUUPO 1 (colonna 1 - colonna 3)
%sono contenuti i dati relativi alla posizione della camera per il frame i
%   GRUPPO 2 (colonna 4 - colonna 6)
%sono contenuti i dati relativi alla rotazione della camera per il frame i
%   GRUPPO3 (colonna7 - colonna 8 )
%sono contenuti i dati relativi alla posizione geografica della camera, quali
%latitudine, longitudine
%   GRUPPO4 (colonna 9)
%è contenuto l'angolo di Fiel of View (FOV) della camera di GES con cui è ripreso il frame

numRow=numFrames+1;

F=zeros(numRow,9);%genero una matrice di zeri
for i=1:numRow %rows
    for j=1:9 %columns
       if j<=3%POSITION
        %get camera position
        pos=val.cameraFrames(i).position;
        if j==1
            F(i,j)=pos.x;
        end
        if j==2
            F(i,j)=pos.y;
        end
        if j==3
            F(i,j)=pos.z;
        end
       end 
    
       if j>3 && j<=6 %ROTATION
        %get camera  rotation
        rot=val.cameraFrames(i).rotation;
        if j==4
            F(i,j)=rot.x;
        end
        if j==5
            F(i,j)=rot.y;
        end
        if j==6
            F(i,j)=rot.z;
        end
       end
       
       if j>6 && j<=8%GEOGRAPHICAL DATA
           geocoords=val.cameraFrames(i).coordinate;
           if j==7
               F(i,j)=geocoords.latitude;
           end
           
           if j==8
               F(i,j)=geocoords.longitude;
           end
           
       end
       
       if j==9 %FOV
           fov=val.cameraFrames(i).fovVertical;
           if j==9
               F(i,j)=fov;
           end
           
       end
               
    end
end

%show final matrix
F


%processiamo i dati 

%RICAVIAMO GLI ANGOLI DI PAN, TILT E ROLL
%vediamo come costruire il sistema di assi CAM0, ovvero l'orientazione
%degli assi della camera quando la camera guarda perpendicolarmente al
%suolo, avendo angoli di Pan,Tilt e Roll posti a 0 su GES. 
%Partendo dall'Equatore con Latitudine 0 e Longitudine 0, consideriamo il
%sistema CAM0 della camera posta all'equatore, ad una certa altitudine. 
%Trasliamo la camera nel centro della Terra, ovvero nell'origine degli assi
%ECEF , ovvero gli assi della Terra. 
%Data Latitudine e Longitudine del luogo, per trovare il sistema CAM0 dobbiamo ruotare gli assi della Terra prima
%intorno all'asse Z secondo l'angolo di Longitudine e poi ruotarli intorno
%al nuovo asse y di un angolo pari a quello di Latitudine.


%map XYZ Earth Axes into Camera Axes:
x_earth=[1,0,0];
y_earth=[0,1,0];
z_earth=[0,0,1];

%JSON file angles for Equator with latitude=0, longitude=0
x_json0=270;
y_json0=-90;
z_json0=0;

%map Earth Axes into Camera ones
%x_json rotation around x earth axis
rv1=deg2rad(x_json0)*x_earth;
R_x=(rotationVectorToMatrix(rv1))';
Xe1=R_x*x_earth';
Ye1=R_x*y_earth';
Ze1=R_x*z_earth';

x1=Xe1';
y1=Ye1';
z1=Ze1';


%y_json rotation around y earth axis
rv2=deg2rad(y_json0)*y1;
R_y=(rotationVectorToMatrix(rv2))';
Xe2=R_y*x1';
Ye2=R_y*y1';
Ze2=R_y*z1';

x2=Xe2';
y2=Ye2';
z2=Ze2';

%z_json rotation around z earth axis
rv3=deg2rad(z_json0)*z2;
R_z=(rotationVectorToMatrix(rv3))';

%sistema CAM0 per l'Equatore
eq_cam0x=R_z*x2';
eq_cam0y=(R_z*y2');
eq_cam0z=(R_z*z2');


%generiamo il sistema di assi ENU. Come origine Locale del sistema ENU è
%stato preso in considerazione il Centro del Colosseo, a Roma.
e0=[0,1,0];
n0=[0,0,1];
u0=[1,0,0];
%see figure for ENU axis orientation (PDF create by GoodNotes)

%first rotation--> e axis
rotVec=deg2rad(Clon)*n0; %rotation around Earth Z
R1=(rotationVectorToMatrix(rotVec))';
e=R1*e0';

%second rotation-->n axis
e_ax=-e';
rotVec2=deg2rad(Clat)*e_ax;%rotation around e parallel to y axis
R2=(rotationVectorToMatrix(rotVec2))';
n=R2*n0';

%u axis
u=cross(e,n);

%Facciamo uno swap degli assi otteuti per allineare gli assi ENU con il
%sistema degli assi nel software di modellazione 3d MAYA.
E=e;
N=u;
U=-n;%metto il segno all'UP per allineare il movimento della camera di GES al sistema del movimento di camera dentro Maya (UP corrisponde all'asse Z di Maya). Se visto dall'alto, il sistema di Maya ha l'asse z che rivolge il suo semiasse positivo verso il basso ed il suo semiasse negativo verso l'alto


%scriviamo l'origine (ovvero il Centro del Colosseo) in
%componenti7coordinate ENU
or=origin-origin;%compute the distance between Coliseum and Coliseum (to compute other vectors we have calculate distances between points and origin (coliseum), so to compute origin to we compute distance between Coliseum and Coliseum that is null (zero) obvoiusly)
Eo_l=dot(or,E);
No_l=dot(or,N);
Uo_l=dot(or,U);
enu_origin=[Eo_l,No_l,Uo_l];

%{
disp('ENU TRACKPOINTS')
trp=val.trackPoints(3)
point=[trp.position.x, trp.position.y,trp.position.z];
track_p=point-origin;
Etrp=dot(track_p,E);
Ntrp=dot(track_p,N);
Utrp=dot(track_p,U);
ENUTP=[Etrp,Ntrp,Utrp];
%}


%sia F1 la matrice in cui organizzeremo i dati processati. 
%{
    Tale matrice è organizzata in questo Modo:
        
        CODICE PER CAMERA AIM 
        
    Ogni riga indicia il frame corrente ed ogni colonna le informazioni
    della camera per ogni frame.

            PRIMO GRUPPO (colonna 1 - colonna3):
                in questo gruppo sono contenute le informazioni relative alle
                posizioni ENU della camera

            SECONDO GRUPPO (colonna 4 - colonna 6):
                in questo gruppo sono contenute le informazioni relative
                agli angoli di Pan, Tilt e Roll. 
    
            

%}

%inizialiaziamo una matrice di tutti zeri 
F1=zeros(numRow,6);

%riempiamo la matrice 
for i=1:numRow
    for j=1:6
        
        if j>=1 && j<=3 %CAMERA ENU POSITION
            
            %calcoliamo il vettore differenza pos che va dal Centro del
            %Colosseo alla Camera
            cam=[F(i,1),F(i,2),F(i,3)];
            [latx,laty,latz]=ecef2geodetic(earth,cam(1),cam(2),cam(3));
            cam_pos=cam-origin;
            
            
            %COMPONENTI ENU DELLA CAMERA 
            %per trovare le componenti ENU della camera, proiettiamo il
            %vettore cam_pos lungo gli assi E,N,U
            E_cam=dot(cam_pos,E);
            N_cam=dot(cam_pos,N);
            U_cam=dot(cam_pos,U);
            
            enu_cam_pos=[E_cam,N_cam,U_cam];
            
            
            %salviamo questi dati nelle prime tre colonne della matrice F1
            if j==1
                F1(i,1)=enu_cam_pos(1);%-4.877;
            end
            if j==2
                F1(i,2)=enu_cam_pos(2);
            end
            if j==3
                F1(i,3)=enu_cam_pos(3);%-11.697;
            end
            
            
        end
        
        
        if j>3 && j<=6 %PAN, TILT E ROLL ANGLES
            
            %   ROTAZIONI 
                      
            %Dai dati del file JSON sulla camera rotation dobbiamo ricavare
            %gli angoli di PAN, TILT e ROLL.
            
            %sia CAM0 è il sistema degli assi della camera sul luogo di
            %latitudine e longitudine data quando gli angoli di PAN, TILT e
            %ROLL sono nulli (dunque la camera guarda penpendicolarmente al
            %suolo. Per trovare CAM0 della camera dobbiamo partire dal CAM0
            %dell'Equatore che abbiamo calcolato precedentemente. 
            %Ruotiamo il CAM0 dell'Equatore prima intorno all'asse Z della Terra di un
            %angolo pari a quello di Longitudine e poi ruotiamo il sistema
            %ottenuto intorno al nuovo asse Y della Terra di un angolo pari
            %a quello di Latitudine. 
            
            %Dunque, troviamo il sistema CAM0 della camera 
            %rotate this cam0 for equator around Z axis (longitude)
            longitude=F(i,8);
            lon=deg2rad(longitude)*z_earth';
            R_lon=(rotationVectorToMatrix(lon))';
            y1e=R_lon*y_earth';

            x2=R_lon*eq_cam0x;
            y2=R_lon*eq_cam0y;
            z2=R_lon*eq_cam0z;

            %rotate this new system around Y axis (latitude)
            latitude=F(i,7);
            lat=deg2rad(-latitude)*y1e';
            R_lat=(rotationVectorToMatrix(lat))';


            x_cam0=R_lat*x2;
            y_cam0=R_lat*y2;
            z_cam0=R_lat*z2;
            
            %   CAM1
            %Ora che abbiamo trovato il sistema CAM0 della camera, dobbiamo
            %trovare il sistema CAM1 della camera, ovvero, come sono
            %orinetati gli assi della camera quando questa è soggetta a
            %rotazioni secondo gli angoli di EULERO
            %E' possibile costruire il sistema CAM1 della camera dagli
            %angoli che ci vengono forniti nel file JSON. Quegli angoli
            %indicano gli angoli delle rotazioni intorno agli assi X,Y,Z
            %per portare (allineare) il sistema degli assi della Terra nel
            %sistema degli assi della camera, dopo che questa sia stata
            %sogetta a rotazioni di angoli di PAN, TITLT  e ROLL (ANGOLI DI
            %EULERO). 
            
            %Dunque, troviamo il sistema CAM1
            %JSON file angles 
            x_json=F(i,4);
            y_json=F(i,5);
            z_json=F(i,6);

            %map Earth Axes into Camera ones
            %x_json rotation around x earth axis
            rv1=deg2rad(x_json)*x_earth;
            R_x=(rotationVectorToMatrix(rv1))';
            Xe1=R_x*x_earth';
            Ye1=R_x*y_earth';
            Ze1=R_x*z_earth';



            %y_json rotation around y earth axis
            rv2=deg2rad(y_json)*Ye1';
            R_y=(rotationVectorToMatrix(rv2))';
            Xe2=R_y*Xe1;
            Ye2=R_y*Ye1;
            Ze2=R_y*Ze1;



            %z_json rotation around z earth axis
            rv3=deg2rad(z_json)*Ze2';
            R_z=(rotationVectorToMatrix(rv3))';

            %CAM1
            x_cam1=R_z*Xe2;
            y_cam1=R_z*Ye2;
            z_cam1=R_z*Ze2;
            
            
            
            %       PAN TILT E ROLL
            %Ora che abbiamo il sistema CAM1 ed il sistema CAM0 della
            %camera possiamo ricavare gli angoli di PAN, TILT e ROLL che
            %portano il sistema CAM0 in CAM1. 
            %Per far questo passaggio "inverso" ci avvaliamo di Wikipedia e
            %dell'articolo "Using Rotation to Build Aerospace Cooridnates"
            
            %check if CAM1 is equal to CAM0 
            %(per vedere se la camera ha subito rotazioni oppure no)
            xt=false;%non ha subito rotazioni (valore di default è true)
            yt=false;%non ha subito rotazioni
            zt=false;%non ha subito rotazioni
            
            %se le cooridnate x,y,z del sistema CAM0 e del sistema CAM1
            %sono uguali, questo significa che la camera non ha subito
            %rotazioni secondo angoli di EULERO, dunque gli angoli di PAN,
            %TILT e ROLL sono NULLI.
            if round(chop(x_cam1,3))==round(chop(x_cam0,3))%chop(x,2) taglio il numero x a sole due cifre decimali poi arrotondo questo numero x con la funzione round
                xt=true;
            end

            if round(chop(y_cam1,3))==round(chop(y_cam0,3))
                yt=true;
            end

            if round(chop(z_cam1,3))==round(chop(z_cam0,3))
                zt=true;
            end

            if xt==true && yt==true && zt==true %angoli di PAN, TILT e ROLL sono NULLI 
                pan=0;
                tilt=0;
                roll=0;
            else %se il sistema CAM0 non coincide con il sistema CAM1 della camera, allora la camera è stata soggetta a rotazioni secondo gli angoli di PAN, TILT  e ROLL, che questa volta sono diversi da 0
                
                %compute psi (pan)
                
                diff1=1- (dot(z_cam1,z_cam0))^2 - (dot(z_cam1,y_cam0))^2;%poichè diff1 andrà sotto il segno di radice, per evitare di lavorare con numeri immaginari, dobbiamo accertarci che il suo valore sia positivo.
                if diff1<0 %pertanto, se il valore di diff1 è negativo, gli cambiamo segno, rendendolo positivo!
                    diffps=-diff1;
                else
                    diffps=diff1;
                end

                pan = rad2deg( atan2( sqrt( diffps ) , -dot(z_cam1,y_cam0) ) );


                %compute theta (tilt)
                
                diff2=1-(dot(z_cam1,z_cam0) )^2;
                if diff2<0
                    difft=-diff2;
                else
                    difft=diff2;
                end


                tilt=rad2deg(atan2((sqrt( difft )),dot(z_cam1,z_cam0) ) );
                
                %compute phi (roll)
                
                diff3=1 - (dot(z_cam1,z_cam0))^2 - (dot(y_cam1,z_cam0))^2 ;
                if diff3<0
                    diffph=-diff3;
                else
                    diffph=diff3;
                end


                roll = rad2deg(atan2(sqrt(diffph ) , dot(y_cam1,z_cam0)  ) );
               
            end
            
            
            
            %inseriamo i valori del camera aim nella matrice F1
            
            if j==4
                F1(i,4)=pan;
            end
            if j==5
                F1(i,5)=tilt;
            end
            if j==6
                F1(i,6)=roll;
            end
            
       
            
            end
        
        
    end
    
end

%mostra la matrice F1
F1



%ora che abbiamo creato la matrice F1, dobbiamo creare una struttura che
%contiene le impostazioni della camera di GES che dovremo ricreare in Maya.
%questi calcoli li faremo al momento di reimpire la struttura frames
Dv=21; %dimensione verticale del sensore della camera di GES in mm
Dh=Dv*1.7;%dimensione orizzonatle del sensore della camera di GES in mm



%Ora, dobbiamo creare il file JSON ed esportarlo!

%il file JSON avrà una struttura simile alla matrice F1 che contiene i dati
%processati con l'aggiunta della struttura GES_Camera.

frames=struct;

%riempiamo la struttura frames
for i=1:numRow
    frames(i).frame=i;
    frames(i).position=struct('x',F1(i,1), 'y',F1(i,2), 'z',F1(i,3));
    frames(i).rotation=struct('pan',F1(i,4), 'tilt',F1(i,5), 'roll',F1(i,6));
    
    %ora che abbiamo creato la matrice F1, dobbiamo creare una struttura che
    %contiene le impostazioni della camera di GES che dovremo ricreare in Maya.
    %ricaviamo il FOV vertical dalla matrice F
    FOVv=F(i,9);
    %ricaviamo il FOV horizontal, sapendo che l'aspect ration tra
    %dimensione orizzontale e verticale è 16:9=1,77
    FOVh=FOVv*1.7;
    %ricaviamo la lunghezza focale applicando la formula di wikipedia!
    alphaMezz=deg2rad(FOVv/2);%metà angolo di FOVv
    d=Dv/2;%metà della dimensione del sensore
    f=d/tan(alphaMezz);%lunghezza focale
    
    frames(i).sensore=struct('horizontal',Dh, 'vertical',Dv);
    frames(i).fov=struct('horizontal',FOVh);
    frames(i).focale=f;
    %frames(i).trackpoint=struct('x',ENUTP(1),'y',ENUTP(2),'z',ENUTP(3));
    
end

%Ora creiamo il file JSON
SF=struct('Frames',frames);
sf=jsonencode(SF)

for i=1:4
    t=val.trackPoints(i).position;
    trckp=[t.x,t.y,t.z];
    tp=trckp-origin;
    a=dot(tp,E);
    b=dot(tp,N);
    c=dot(tp,U);
    T=[a,b,c,]
end






%copiare il contenuto della stringa sf generata ed inserirla in una file
%JSON 
%Per una corretta creazione di un file JSON, copiare un file JSON esistente nella cartella
% C:\Users\PythonEnv
%e modificarlo con un editor, ad esempio, Netbeans, ed incollare il contenuto della stringa sf

%Ora che abbiamo creato il nostro file JSON siamo pronti per passare a
%programmare lo script Python per Maya!

