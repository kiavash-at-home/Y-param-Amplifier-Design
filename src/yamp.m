%Filename: yamp.m
%--------------------------------------------------------
%INPUT: Y parameter of active device
%OUTPUT: Yl & Ys (input & output admitance) of device
%--------------------------------------------------------
%This M file Caculate Input & Output admitance
%of active device. (Yl & Ys) They must be matched to refrence admitance.
%
%              ----------
%-------------|          |------------
%|            | 2-Port   |           |
%Ys    Y1 ->  | Network  | <- Y2     Yl
%|            |          |           |
%_             ----------            _
%-                                   -
%GND                                GND

%{
Copyright 1996 by Kiavash
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    https://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
%}

clc
clear
i=sqrt(-1);
  disp('This program calculate the matching circuit by using "Y parameters"');
  disp('Input "Y parameters"');
  
% Input data routine
  gi=input('gi(Ʊ)=');
     bi=input('bi(Ʊ)=');
  go=input('go(Ʊ)=');
     bo=input('bo(Ʊ)=');
  af=input('|Yf|(Ʊ)=');
     bf=input('<Yf(°)=');
  ar=input('|Yr|(Ʊ)=');
     br=input('<Yr(°)=');

%Calculate Complex Y parameter
  Yf=af .* exp(i .* bf .* pi ./180);
  Yr=ar .* exp(i .* br .* pi ./180);
  Yi=gi + i .* bi;
  Yo=go + i .* bo;



  MAG=(abs(Yf) .^ 2) ./ (4 .* real(Yi) .* real(Yo));
  disp('  ');
  disp(['Maximum Available Gain= ' num2str(10*log10(MAG)) ' dB']);

%Calculate C factor
  C=abs(Yf .* Yr) ./ (2 .* real(Yi) .* real(Yo) - real(Yf .* Yr))

repeat=1;
while repeat == 1 ,
%Check that it is Stable or Unstable
  if C < 1
        %Stable
        disp('Your active device is unconitionally stable "U.S."');

   %Calculate Input marching
        disp('Admitance that active should see in input is (Ys=Gs + j Bs) in (Ʊ)');
        temp=sqrt((2 .* real(Yi) .* real(Yo) - real(Yf .* Yr)) .^ 2 - (abs(Yf .* Yr)) .^ 2);
        Gs=temp ./ (2 .* real(Yo))
        Bs= - imag(Yi) + (imag(Yf .* Yr) ./ (2 .* real(Yo)))
        Ys=Gs + i.* Bs;
       
   %Calculate Output matching
        disp('Admitance that active device should see in output is (Yl = Gl + j Bl) in (Ʊ)');
        Gl= Gs .* real(Yo) ./ real(Yi)
        Bl= - imag(Yo) + (imag(Yf .* Yr) ./ (2 .* real(Yi)))
        Yl=Gl + i.* Bl;
  else
        %Unstable
        disp(' ');
        disp('Your active device is potentially unstable "P.U."');
        disp('thus you should input K factor of circuit');

        disp(' ');
        K=input('K=  (4<K<10)');
        while (K> 10) | (K<4) ,
              disp('Input K between 4 and 10,please (4<K<10)');
              K=input('K=  (4<K<10)');
        end


        Question=input('Enter 1 if you want to determine Gs?');

        if Question==1
           Gs=input('Gs=');
        else
           temp=K .* (abs(Yf .* Yr) + real(Yi).*real(Yf .* Yr)) ./ 2;
           Gs=sqrt(temp ./ real(Yo)) - real(Yi);
        end

   %Calculate Input & Output Admitance
         temp=K .* (abs(Yf .* Yr) + real(Yf .* Yr)) ./ 2;
         Gl=(temp ./ (real(Yi)+Gs))-real(Yo);

         Bl1=0;
         Bl2=-imag(Yo);

         while Bl1 ~= Bl2 ,
               Bl1=Bl2;
               Yl=Gl + i .* Bl1;
               Y1=Yi - (Yf .* Yr ./ (Yo + Yl));
               Bs1=- imag(Y1);
               Ys=Gs + i .* Bs1;
               Y2=Yo - (Yf .* Yr ./ (Yi + Ys));
               Bl2=- imag(Y2);
               Yl=Gl + i .* Bl2;
               Y1=Yi - (Yf .* Yr ./ (Yo + Yl));
               Bs2=- imag(Y1);
          end

         Bl=Bl2;
         Bs=Bs2;

        disp(' ');
        disp('Source Admitance is (Ys=Gs + j Bs) in (Ʊ)');
        Ys=Gs + i.* Bs
        disp('Load Admitance is (Yl=Gl + j Bl) in (Ʊ)');
        Yl=Gl + i.* Bl
  end
 Gt=(4 .* Gs .* Gl .* abs(Yf) .^ 2) ./ (abs((Yi+Ys).*(Yo+Yl) - Yf .* Yr)).^2;
 disp(' ');
 disp(['Gt= ' num2str(10*log10(Gt)) ' dB']);

 disp('Input Admitance of active device is (Ʊ)');
 Y1=Yi - (Yf .* Yr ./ (Yo + Yl))

 disp('Output Admitance of active device is (Ʊ)');
 Y2=Yo - (Yf .* Yr ./ (Yi + Ys))

disp(' ');
repeat=input('Enter 1 to re-run the program again.');
end
