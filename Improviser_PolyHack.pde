import processing.sound.*;
import processing.net.*;

/*Instance Variables*/
SinOsc sin, sin1, sin2, sin3, sin4, sin5, 
sin6, sin7, sin8, sin9, sin10;
SoundFile file;
LowPass lowPass;   
float frequency = 440;
float rootAmp = .019;
static Integer lastOctave = new Integer(0);
static Integer lastNote = new Integer(0);
final int BPM = 170;
int noteLength = 1;// 16 = whole, 8 = half, 4 = quarter, 2 = 8th, 1 16th.
int songLocation = 0;// quarter notes into song
int songLength = 188;// seconds
int fadeCount = 0;
int [] chordArray = {3, 8, 1, 6, 0, 5, 10, 10, 3, 8, 1, 6, 0, 5, 10, 10, 0, 5, 10, 10, 3, 8, 1, 1, 0, 5, 10, 10, 0, 5, 10, 10,};
int [] chordTypeArray = {4, 3, 2, 2, 5, 3, 4, 3, 4, 3, 2, 2, 5, 3, 4, 3, 5, 3, 4, 3, 4, 3, 2, 2, 5, 3, 4, 4, 5, 3, 4, 3};
boolean playing = true; 
boolean resting = false; 
float sa = .80, s1a = .90, s2a = .80, s3a = .75, s4a = .80, s5a = .22, s6a = .14, s7a = .34, s8a =.20,
s9a = .10, s10a = .10;
Amplitude songAmp;
double [] ampArray;
 
void setup(){
    fullScreen();
    background(0);
    frameRate(2*BPM/15);//One frame is a 32th note

    sin = new SinOsc(this);
    sin1 = new SinOsc(this);
    sin2 = new SinOsc(this);
    sin3 = new SinOsc(this);
    sin4 = new SinOsc(this);
    sin5 = new SinOsc(this);
    sin6 = new SinOsc(this);
    sin7 = new SinOsc(this);
    sin8 = new SinOsc(this);
    sin9 = new SinOsc(this);
    sin10 = new SinOsc(this);
    
    setAmplitude();
    setFrequency();
    
    songAmp = new Amplitude(this);
    file = new SoundFile(this,"Autumn Leaves Bb 170.wav");
    file.play();
    songAmp.input(file);
    
    file.play();
    sin.play();
    sin1.play();
    sin2.play();
    sin3.play();
    sin4.play();
    sin5.play();
    sin6.play();
    sin7.play();
    sin8.play();
    sin9.play();
    sin10.play();
    
   ampArray = new double[2*BPM/15*songLength*60 + 2]; //frames per second x number of frames (+1 as frames start at 1)
   
}

void draw(){
    if (frameCount/frameRate <= songLength){
        int songKey = 1;
        int chordLetter = getChordLetter();
        int chordType = getChordType();
        println(chordLetter);
        ampArray [0] = songAmp.analyze();
        ampArray[frameCount] = songAmp.analyze();
        rootAmp += (ampArray[frameCount] - ampArray[frameCount-1])/15;
        if (changeNote()){
            if (noteLength != 2){
                resting = rest();
            }
            noteLength = getNoteLength(frameCount/frameRate, songLength);
            if (resting && noteLength != 2){
                noteLength /= 2;
            }
            if (!resting){
                fadeCount = 0;
                frequency = (float) getFrequency(songKey, chordLetter, chordType);
                setFrequency();
                setAmplitude();
                //background(frequency%255,((frequency + 100)%255),((frequency + 50)%255));
            }
            if (resting){
                fadeCount = 1;
                fadeAmplitude();
                //background(0);
            }
        }
        if (resting){
            fadeCount++;
            if (fadeCount < 3){
                fadeAmplitude();
            }
            else{
                zeroAmplitude();
            }
        }
        
        
        //Graphical Display
        strokeWeight(25);
        if (!resting){
            stroke(random(0,255), random(0,255), random(0,255));
        }
        else{
            stroke(0);  
        }
        /*
        point(4*(frameCount)%displayWidth, 10000*-amp.analyze()+displayHeight/2);
        point(4*frameCount%displayWidth, 10000*amp.analyze()+displayHeight/2);
        point(10000*-amp.analyze() + displayWidth/2, 4*frameCount%displayHeight);
        point(10000*amp.analyze() + displayWidth/2, 4*frameCount%displayHeight);
        
        point(displayWidth - 4*frameCount%displayWidth, 10000*-amp.analyze()+displayHeight/2);
        point(displayWidth -4*frameCount%displayWidth, 10000*amp.analyze()+displayHeight/2);
        point(10000*-amp.analyze() + displayWidth/2, displayHeight-4*frameCount%displayHeight);
        point(10000*amp.analyze() + displayWidth/2, displayHeight-4*frameCount%displayHeight);
        */
        noFill();
        ellipse(displayWidth/2, displayHeight/2, 4*frameCount%displayHeight, 4*frameCount%displayHeight);
        ellipse(displayWidth/4, displayHeight/4, 4*frameCount%(displayHeight/2), 4*frameCount%(displayHeight/2));
        ellipse(displayWidth/4, 3*displayHeight/4, 4*frameCount%(displayHeight/2), 4*frameCount%(displayHeight/2));
        ellipse(3*displayWidth/4, displayHeight/4, 4*frameCount%(displayHeight/2), 4*frameCount%(displayHeight/2));
        ellipse(3*displayWidth/4, 3*displayHeight/4, 4*frameCount%(displayHeight/2), 4*frameCount%(displayHeight/2));
    }
    else {
        zeroAmplitude();
        //chill w display;
    }
}

boolean changeNote(){
    if (frameCount%noteLength == 0){
       return true;
    }
    return false;
}

boolean rest(){
    int randRest = (int) random(0,100);
    if (frameCount/frameRate < songLength/4){
      if (randRest < 25){
          return true;
      }
    }
    else if (frameCount/frameRate < songLength/2){
      if (randRest < 17){
          return true;
      }
    }
    else if (frameCount/frameRate < 3*songLength/4){
      if (randRest < 10){
          return true;
      }
    }
    else if (frameCount/frameRate < songLength){
      if (randRest < 0){
          return true;
      }
    }
    return false; 
}

int getChordLetter(){
    songLocation = frameCount%1024;
    return chordArray[songLocation/32];
}

int getChordType(){
    songLocation = frameCount%1024;
    return chordTypeArray[songLocation/32];
}

void setAmplitude(){
   sin.amp(sa*rootAmp);
   sin1.amp(s1a*rootAmp);
   sin2.amp(s2a*rootAmp);
   sin3.amp(s3a*rootAmp);
   sin4.amp(s4a*rootAmp);
   sin5.amp(s5a*rootAmp);
   sin6.amp(s6a*rootAmp);
   sin7.amp(s7a*rootAmp);
   sin8.amp(s8a*rootAmp);
   sin9.amp(s9a*rootAmp);
   sin10.amp(s10a*rootAmp);
}

void fadeAmplitude(){
    //decrease 2 times to zero. 
    sin.amp(sa*rootAmp - (sa/2)*rootAmp*fadeCount);
    sin1.amp(s1a*rootAmp - (s1a/2)*rootAmp*fadeCount);
    sin2.amp(s2a*rootAmp - (s2a/2)*rootAmp*fadeCount);
    sin3.amp(s3a*rootAmp - (s3a/2)*rootAmp*fadeCount);
    sin4.amp(s4a*rootAmp - (s4a/2)*rootAmp*fadeCount);
    sin5.amp(s5a*rootAmp - (s5a/2)*rootAmp*fadeCount);
    sin6.amp(s6a*rootAmp - (s6a/2)*rootAmp*fadeCount);
    sin7.amp(s7a*rootAmp - (s7a/2)*rootAmp*fadeCount);
    sin8.amp(s8a*rootAmp - (s8a/2)*rootAmp*fadeCount);
    sin9.amp(s9a*rootAmp - (s9a/2)*rootAmp*fadeCount);
    sin10.amp(s10a*rootAmp - (s10a/2)*rootAmp*fadeCount);
}

void zeroAmplitude(){
    sin.amp(0);
    sin1.amp(0);
    sin2.amp(0);
    sin3.amp(0);
    sin4.amp(0);
    sin5.amp(0);
    sin5.freq(0);
    sin6.freq(0);
    sin7.freq(0);
    sin8.freq(0);
    sin9.freq(0);
    sin10.freq(0);
}

void setFrequency(){
    sin.freq(.5*frequency + random(-.04, .04));
    sin1.freq(1*frequency + random(-.04,.04));
    sin2.freq(1.5*frequency + random(-.04,.04));
    sin3.freq(2*frequency + random(-.04,.04));
    sin4.freq(3*frequency + random(-.04,.04));
    sin5.freq(4*frequency + random(-.04,.04));
    sin6.freq(5*frequency + random(-.04,.04));
    sin7.freq(6*frequency + random(-.04,.04));
    sin8.freq(7*frequency + random(-.04,.04));
    sin9.freq(8*frequency + random(-.04,.04));
    sin10.freq(9*frequency + random(-.04,.04));
}

private static int getNoteLength(double time, double length){
    int maxPercent = 40;
    int[] array = new int[100];
    int whole, half, quarter, eighth, sixteenth;
    //
    int y = (100 - maxPercent) / 4;
    int z = 100 - (maxPercent + 3 * y);
    int change;
    // 0 is whole, 1 is half, 2 is quarter, 3 is eighth, 4 is sixteenth
    int[] percentages = new int[5];
    if (time / length < .25) {
        change = (int)(((time / length - .25) / .25) * (maxPercent-y));
        percentages[0] = y;
        percentages[1] = y;  
        percentages[2] = maxPercent - change;
        percentages[3] = y + change;
        percentages[4] = z;
    }
    else if (time / length < .5) { 
        change = (int)(((time / length - .5) / .25) * (maxPercent-y));
        y = (100 - maxPercent) / 3;
        z = 100 - (maxPercent + 2 * y);
        percentages[0] = 0;
        percentages[1] = y;  
        percentages[2] = y;
        percentages[3] = maxPercent;
        percentages[4] = z;
    }
    else if (time / length < .60) {
        change = (int)(((time / length - .5) / .25) * (maxPercent-y));
        y = (100 - maxPercent) / 3;
        z = 100 - (maxPercent + 2 * y);
        percentages[0] = 0;
        percentages[1] = y;  
        percentages[2] = y;
        percentages[3] = maxPercent;
        percentages[4] = z;
    }
    else {
        y = (100 - maxPercent) / 2;
        z = 100 - (maxPercent + y);
        change = z / 2;
        percentages[0] = 0;
        percentages[1] = 0;  
        percentages[2] = z - change;
        percentages[3] = y;
        percentages[4] = maxPercent + change;
    }
    whole = percentages[0];
    half = percentages[1] + whole;
    quarter = percentages[2] + half;
    eighth = percentages[3] + quarter;
    sixteenth = percentages[4] + eighth;
    /*if (whole + half + quarter + eighth + sixteenth != 100) {
    error;
    }*/
    // The above should never happen because of how they are set up.  Let's hope
    int i;
    // Whole note
    for (i = 0; i < whole; i++) {
        array[i] = 32;
    }
    // Half note
    for (; i < half; i++) {
        array[i] = 16;
    }
    // Quarter note
    for (; i < quarter; i++) {
        array[i] = 8;
    }
    // Eighth note
    for (; i < eighth; i++) {
        array[i] = 4;
    }
    // Sixteenth note
    for (; i < sixteenth; i++) {
        array[i] = 2;
    }
    int random = (int)Math.floor(Math.random() * 100);
    return (array[random]);
}

//calling notes[] as the note defined table in gdoc
//calling quality[] as the chord defined table in gdoc
public static double getFrequency(int songKey, int chordLetter, int chordType) {
    //These is way of determining probability. Eventually find random index in percents. Add to percents with countPercents
    int[] percents = new int[100];
    int countPercents;
    
    //note distribution
    //must generate notes in this order for percents to work!!
    int perLastNote = 10;
    int perChordType = 80 + perLastNote;
    int perNotKey = 10 + perChordType;
    int perKey = 100;
    int perOctChange = 20;
    
    //making first ___ values the same as last note
    for (countPercents = 0; countPercents < perLastNote; countPercents++) {
        percents [countPercents] = lastNote;
    }
    
    //make first ___ values within chords
        switch (chordType) {
            case 0: 
                while (countPercents < perChordType) {
                    percents [countPercents] = chordLetter;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 4) % 12;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 7) % 12;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 2) % 12;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 5) % 12;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 9) % 12;
                    countPercents++;
                    if (countPercents == 100) break;
                    percents [countPercents] = (chordLetter + 10) % 12;
                    countPercents++;
                }
                break;
            case 1: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 3) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 7) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 2) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 10) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 4) % 12;
                countPercents++;
                }
                break;
            case 2: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 4) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 7) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 11) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 2) % 12;
                countPercents++;
                }
                if (countPercents == 100) break;
                break;
            case 3: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 4) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 7) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 10) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 2) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 5) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 9) % 12;
                countPercents++;
                }
                break;
            case 4: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 3) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 7) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 10) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 2) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 5) % 12;
                countPercents++;
                }
                break;
            case 5: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 3) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 6) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 10) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 2) % 12;
                countPercents++;
                if (countPercents == 100) break;
                percents [countPercents] = (chordLetter + 5) % 12;
                countPercents++;
                }
                break;
            default: while (countPercents < perChordType) {
                percents [countPercents] = chordLetter;
                countPercents++;
                }
                break;
                
        }
    while (countPercents < perNotKey) {
            percents [countPercents] = (songKey + 1);
            countPercents++;
            if (countPercents == 100) break;
            percents [countPercents] = (songKey + 3) % 12;
            countPercents++;
            if (countPercents == 100) break;
            percents [countPercents] = (songKey + 6) % 12;
            countPercents++;
            if (countPercents == 100) break;
            percents [countPercents] = (songKey + 8) % 12;
            countPercents++;
            if (countPercents == 100) break;
            percents [countPercents] = (chordLetter + 10) % 12;
            countPercents++;
        }
    
    //make ___ values within key
    while (countPercents < perKey) {
        percents [countPercents] = (songKey);
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 2) % 12;
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 4) % 12;
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 5) % 12;
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 7) % 12;
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 9) % 12;
        countPercents++;
        if (countPercents == 100) break;
        percents [countPercents] = (songKey + 11) % 12;
        countPercents++;
    }
    
    //picking note out of percents
    int randomInt = (int) (Math.random()*100);
    //this is the note to convert
    //NEEDS TO SET lastNote outside of function
    lastNote = percents[randomInt];
    double finalNote = 1.0 * lastNote;
    //hertz convert
    double finalHertz = 440.0*(Math.pow(2.0, (finalNote/12)));
    
    //choose octave
    int randomOct = (int) (Math.random()*4);
    
    //how often oct will change
    int[] percentOct = new int[100];
    for (int i = 0; i < perOctChange; i++) {
        percentOct [i] = -1;
        i++;
        if (i == perOctChange) break; 
        percentOct [i] = 0;
        i++;
        if (i == perOctChange) break; 
        percentOct [i] = 1;
        i++;
        if (i == perOctChange) break;
        percentOct [i] = 2;
        i++;
        if (i == perOctChange) break; 
    }
    
    for (int i = 0; i < (100 - perOctChange); i++) {
        percentOct [i] = lastOctave;
    }
    
    lastOctave = percentOct [randomOct];
    finalHertz = Math.pow(2, lastOctave) * finalHertz;
    
    return finalHertz;  
}