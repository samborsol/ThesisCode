#!/bin/sh
 

b=$(sed -ne "${1}{p;q;}" files.txt)

cat > TRV1EPPlotting_${1}.C << +EOF

#include<TH1F>
#include<TProfile>
#include<iostream>
#include<iomanip>
#include"TFile.h"
#include"TTree.h"
#include"TLeaf.h"
#include"TChain.h"
//Functions in this macro///
void Initialize();
void FillPTStats();
void FillAngularCorrections();
void FlowAnalysis();
////////////////////////////


//Files and chains
TChain* chain2;//= new TChain("hiGoodTightMergedTracksTree");


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
////////////           GLOBAL VARIABLES            //////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
Float_t pi=TMath::Pi();
Int_t vterm=1;//Set which order harmonic that this code is meant to measure
const Int_t jMax=10;////Set out to which order correction we would like to apply
Int_t NumberOfEvents=0;
//NumberOfEvents=1;
//NumberOfEvents=2;
//NumberOfEvents=10;
//NumberOfEvents=100;
//NumberOfEvents=50000;
//NumberOfEvents=100000;
//NumberOfEvents=5000000;
//  NumberOfEvents = chain->GetEntries();

const Int_t nCent=5;//Number of Centrality classes

///Looping Variables
Int_t Centrality=0; //This will be the centrality variable later
Int_t NumberOfHits=0;//This will be for both tracks and Hits
Float_t pT=0.;
Float_t phi=0.;
Float_t eta=0.;



Float_t centlo[nCent];
Float_t centhi[nCent];
centlo[0]=0;  centhi[0]=10;
centlo[1]=10;  centhi[1]=20;
centlo[2]=20;  centhi[2]=30;
centlo[3]=30;  centhi[3]=40;
centlo[4]=40;  centhi[4]=50;

//Create the output ROOT file
TFile *myFile;

//PT Bin Centers
TProfile *PTCenters[nCent];

//EP Resolution Plots

//For Resolution of V1 Even
TProfile *TRPMinusTRM[nCent];
TProfile *TRMMinusTRC[nCent];
TProfile *TRPMinusTRC[nCent];

//For Resolution of V1 Odd
TProfile *TRPMinusTRMOdd[nCent];
TProfile *TRMMinusTRCOdd[nCent];
TProfile *TRPMinusTRCOdd[nCent];


//Make Subdirectories for what will follow
TDirectory *myPlots;//the top level
TDirectory *epangles;//where i will store the ep angles
TDirectory *outerep;
TDirectory *posep;
TDirectory *negep;
TDirectory *midep;

TDirectory *resolutions;//top level for resolutions
TDirectory *psioneoddres;//where i will store standard EP resolution plots
TDirectory *psioneevenres;//where i will store psi1(even)

TDirectory *v1plots;//where i will store the v1 plots
TDirectory *v1etaoddplots;//v1(eta) [odd] plots
TDirectory *v1etaevenplots; //v1(eta)[even] plots
TDirectory *v1ptevenplots; //v1(pT)[even] plots
TDirectory *v1ptoddplots;//v1(pT)[odd] plots

//TProfiles to save <pT> and <pT^2> info ....All this is for Ollitrault weights
Float_t ptavwhole[nCent]={0.},pt2avwhole[nCent]={0.};
Float_t ptavpos[nCent]={0.},pt2avpos[nCent]={0.};
Float_t ptavneg[nCent]={0.},pt2avneg[nCent]={0.};
Float_t ptavmid[nCent]={0.},pt2avmid[nCent]={0.};

//Looping Variables
//v1 even
Float_t X_wholetracker[nCent]={0.},Y_wholetracker[nCent]={0.},
  X_postracker[nCent]={0.},Y_postracker[nCent]={0.},
  X_negtracker[nCent]={0.},Y_negtracker[nCent]={0.},
  X_midtracker[nCent]={0.},Y_midtracker[nCent]={0.};

//v1 odd
Float_t X_wholeoddtracker[nCent]={0.},Y_wholeoddtracker[nCent]={0.},
  X_posoddtracker[nCent]={0.},Y_posoddtracker[nCent]={0.},
  X_negoddtracker[nCent]={0.},Y_negoddtracker[nCent]={0.},
  X_midoddtracker[nCent]={0.},Y_midoddtracker[nCent]={0.};



//////////////////////////////////////
// The following variables and plots
// are for the AngularCorrections
// function
///////////////////////////////////////


//These Will store the angular correction factors
//v1 even
//Whole Tracker
Float_t CosineWholeTracker[nCent][jMax],SineWholeTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosTracker[nCent][jMax],SinePosTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegTracker[nCent][jMax],SineNegTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidTracker[nCent][jMax],SineMidTracker[nCent][jMax];

//v1 odd
//Whole Tracker
Float_t CosineWholeOddTracker[nCent][jMax],SineWholeOddTracker[nCent][jMax];

//Pos Tracker
Float_t CosinePosOddTracker[nCent][jMax],SinePosOddTracker[nCent][jMax];

//Neg Tracker
Float_t CosineNegOddTracker[nCent][jMax],SineNegOddTracker[nCent][jMax];

//Mid Tracker
Float_t CosineMidOddTracker[nCent][jMax],SineMidOddTracker[nCent][jMax];

//EP Plots
//Even
   //Whole Tracker
TH1F *PsiEvenRaw[nCent];
TH1F *PsiEvenFinal[nCent];
   //Pos Tracker
TH1F *PsiPEvenRaw[nCent];
TH1F *PsiPEvenFinal[nCent];
   //Neg Tracker
TH1F *PsiNEvenRaw[nCent];
TH1F *PsiNEvenFinal[nCent];
   //Mid Tracker
TH1F *PsiMEvenRaw[nCent];
TH1F *PsiMEvenFinal[nCent];

//Odd
  //Whole Tracker 
TH1F *PsiOddRaw[nCent];
TH1F *PsiOddFinal[nCent];
   //Pos Tracker
TH1F *PsiPOddRaw[nCent];
TH1F *PsiPOddFinal[nCent];
   //Neg Tracker
TH1F *PsiNOddRaw[nCent];
TH1F *PsiNOddFinal[nCent];
   //Mid Tracker
TH1F *PsiMOddRaw[nCent];
TH1F *PsiMOddFinal[nCent];
/////////////////////////////////////////
/// Variables that are used in the //////
// Flow Analysis function////////////////
/////////////////////////////////////////

//RAW EP's
Float_t EPwholetracker=0.,EPpostracker=0.,EPnegtracker=0.,EPmidtracker=0.,
  EPwholeoddtracker=0.,EPposoddtracker=0.,EPnegoddtracker=0.,EPmidoddtracker=0.;


//v1 even stuff
Float_t AngularCorrectionWholeTracker=0.,EPfinalwholetracker=0.,
  AngularCorrectionPosTracker=0.,EPfinalpostracker=0.,
  AngularCorrectionNegTracker=0.,EPfinalnegtracker=0.,
  AngularCorrectionMidTracker=0.,EPfinalmidtracker=0.;


//v1 odd

Float_t AngularCorrectionWholeOddTracker=0.,EPfinalwholeoddtracker=0.,
  AngularCorrectionPosOddTracker=0.,EPfinalposoddtracker=0.,
  AngularCorrectionNegOddTracker=0.,EPfinalnegoddtracker=0.,
  AngularCorrectionMidOddTracker=0.,EPfinalmidoddtracker=0.;


/////////////////
///FLOW PLOTS////
////////////////
TProfile *V1EtaOdd[nCent];
TProfile *V1EtaEven[nCent];
TProfile *V1PtEven[nCent];
TProfile *V1PtOdd[nCent];

///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////
/////////////////// END OF GLOBAL VARIABLES ///////////////////////
///////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////

//Running the Macro
Int_t TRV1EPPlotting_${1}(){//put functions in here
  Initialize();
  FillPTStats();
  FillAngularCorrections();
  FlowAnalysis();
  return 0;
}

void Initialize(){

  float eta_bin_small[13]={-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0.0,0.1,0.2,0.3,0.4,0.5,0.6};

  double pt_bin[17]={0.4,0.6,0.8,1.0,1.2,1.4,1.6,1.8,2.0,2.4,2.8,3.2,3.6,4.5,6.5,9.5,12};

  chain2= new TChain("hiGoodTightMergedTracksTree");

  //Tracks Tree
  chain2->Add("/hadoop/store/user/jgomez2/ForwardTrees/2010/PanicTime/$b");

    NumberOfEvents= chain2->GetEntries();
  //Create the output ROOT file
  myFile = new TFile("TREP_EPPlotting_${1}.root","recreate");

  //Make Subdirectories for what will follow
  myPlots = myFile->mkdir("Plots");
  myPlots->cd();

  //Directory for the EP angles
  epangles = myPlots->mkdir("EventPlanes");
  //Outer Tracker
  outerep = epangles->mkdir("WholeTracker");
  //Pos Tracker
  posep = epangles->mkdir("PositiveTracker");
  //Negative Tracker
  negep = epangles->mkdir("NegativeTracker");
  //Mid Tracker
  midep = epangles->mkdir("CentralTracker");

  //Directory for Resolution Plots
  resolutions = myPlots->mkdir("EventPlaneResolutions");
  psioneevenres = resolutions->mkdir("PsiOneEvenResolution");
  psioneoddres = resolutions->mkdir("PsiOneOddResolution");


  //Directory For Final v1 plots
  v1plots = myPlots->mkdir("V1Results");
  v1etaoddplots = v1plots->mkdir("V1EtaOdd");
  v1etaevenplots = v1plots->mkdir("V1EtaEven");
  v1ptevenplots = v1plots->mkdir("V1pTEven");
  v1ptoddplots = v1plots->mkdir("V1pTOdd");




  char ptcentname[128];
  char ptcenttitle[128];

  char res4name[128],res4title[128];
  char res5name[128],res5title[128];
  char res6name[128],res6title[128];

  //Psi1 Raw, Psi1 Final
  //Psi1(even)
  //Whole Tracker
  char epevenrawname[128],epevenrawtitle[128];
  char epevenfinalname[128],epevenfinaltitle[128];
  //Pos Tracker
  char pevenrawname[128],pevenrawtitle[128];
  char pevenfinalname[128],pevenfinaltitle[128];
  //Neg Tracker
  char nevenrawname[128],nevenrawtitle[128];
  char nevenfinalname[128],nevenfinaltitle[128];
  //Mid Tracker
  char mevenrawname[128],mevenrawtitle[128];
  char mevenfinalname[128],mevenfinaltitle[128];

  //Psi1(odd)
  //Whole Tracker
  char epoddrawname[128],epoddrawtitle[128];
  char epoddfinalname[128],epoddfinaltitle[128];
  //Pos Tracker
  char poddrawname[128],poddrawtitle[128];
  char poddfinalname[128],poddfinaltitle[128];
  //Neg Tracker
  char noddrawname[128],noddrawtitle[128];
  char noddfinalname[128],noddfinaltitle[128];
  //Mid Tracker
  char moddrawname[128],moddrawtitle[128];
  char moddfinalname[128],moddfinaltitle[128];


  //V1 Plots
  char v1etaoddname[128],v1etaoddtitle[128];
  char v1etaevenname[128],v1etaeventitle[128];
  char v1ptoddname[128],v1ptoddtitle[128];
  char v1ptevenname[128],v1pteventitle[128];


  //V1 odd resolutions
  char v1oddres1name[128],v1oddres1title[128];
  char v1oddres2name[128],v1oddres2title[128];
  char v1oddres3name[128],v1oddres3title[128];

  for (int i=0;i<nCent;i++)
    {
      //V1 odd eta
      v1etaoddplots->cd();
      sprintf(v1etaoddname,"V1EtaOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaoddtitle,"v_{1}^{odd}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaOdd[i]= new TProfile(v1etaoddname,v1etaoddtitle,12,eta_bin_small);

      //v1 even eta
      v1etaevenplots->cd();
      sprintf(v1etaevenname,"V1EtaEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1etaeventitle,"v_{1}^{even}(#eta) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1EtaEven[i]= new TProfile(v1etaevenname,v1etaeventitle,12,eta_bin_small);

      //v1 pt even
      v1ptevenplots->cd();
      sprintf(v1ptevenname,"V1PtEven_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1pteventitle,"v_{1}^{even}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtEven[i]= new TProfile(v1ptevenname,v1pteventitle,16,pt_bin);


      //v1 pt odd
      v1ptoddplots->cd();
      sprintf(v1ptoddname,"V1PtOdd_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1ptoddtitle,"v_{1}^{odd}(p_{T}) for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      V1PtOdd[i]= new TProfile(v1ptoddname,v1ptoddtitle,16,pt_bin);

      v1plots->cd();
      sprintf(ptcentname,"pTcenter_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(ptcenttitle,"Bin Center for %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      PTCenters[i]= new TProfile(ptcentname,ptcenttitle,16,pt_bin); //or can make a TH1f and fill a specific range
/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////
      //Event Plane Plots
      outerep->cd();
      //Psi1Even
      //Whole Tracker
      //Raw
      sprintf(epevenrawname,"Psi1EvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenrawtitle,"#Psi_{1}^{even} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenRaw[i] = new TH1F(epevenrawname,epevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(epevenfinalname,"Psi1EvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epevenfinaltitle,"#Psi_{1}^{even} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiEvenFinal[i] = new TH1F(epevenfinalname,epevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(pevenrawname,"Psi1PEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenrawtitle,"#Psi_{1}^{even}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenRaw[i] = new TH1F(pevenrawname,pevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(pevenfinalname,"Psi1PEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(pevenfinaltitle,"#Psi_{1}^{even}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPEvenFinal[i] = new TH1F(pevenfinalname,pevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(nevenrawname,"Psi1NEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenrawtitle,"#Psi_{1}^{even}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenRaw[i] = new TH1F(nevenrawname,nevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(nevenfinalname,"Psi1NEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(nevenfinaltitle,"#Psi_{1}^{even}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNEvenFinal[i] = new TH1F(nevenfinalname,nevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(mevenrawname,"Psi1MEvenRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenrawtitle,"#Psi_{1}^{even}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenRaw[i] = new TH1F(mevenrawname,mevenrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(mevenfinalname,"Psi1MEvenFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(mevenfinaltitle,"#Psi_{1}^{even}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMEvenFinal[i] = new TH1F(mevenfinalname,mevenfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMEvenFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      //Psi1Odd
      outerep->cd();
      //WholeTracker
      //Raw
      sprintf(epoddrawname,"Psi1OddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddrawtitle,"#Psi_{1}^{odd} Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddRaw[i] = new TH1F(epoddrawname,epoddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(epoddfinalname,"Psi1OddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(epoddfinaltitle,"#Psi_{1}^{odd} Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiOddFinal[i] = new TH1F(epoddfinalname,epoddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Pos Tracker
      posep->cd();
      //Raw
      sprintf(poddrawname,"Psi1POddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddrawtitle,"#Psi_{1}^{odd}(TR^{+}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddRaw[i] = new TH1F(poddrawname,poddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(poddfinalname,"Psi1POddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(poddfinaltitle,"#Psi_{1}^{odd}(TR^{+}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiPOddFinal[i] = new TH1F(poddfinalname,poddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiPOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Neg Tracker
      negep->cd();
      //Raw
      sprintf(noddrawname,"Psi1NOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddrawtitle,"#Psi_{1}^{odd}(TR^{-}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddRaw[i] = new TH1F(noddrawname,noddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(noddfinalname,"Psi1NOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(noddfinaltitle,"#Psi_{1}^{odd}(TR^{-}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiNOddFinal[i] = new TH1F(noddfinalname,noddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiNOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");

     //Mid Tracker
      midep->cd();
      //Raw
      sprintf(moddrawname,"Psi1MOddRaw_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddrawtitle,"#Psi_{1}^{odd}(TR^{mid}) Raw %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddRaw[i] = new TH1F(moddrawname,moddrawtitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddRaw[i]->GetXaxis()->SetTitle("EP Angle (radians)");
      //Final
      sprintf(moddfinalname,"Psi1MOddFinal_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(moddfinaltitle,"#Psi_{1}^{odd}(TR^{mid}) Final %1.0lfto%1.0lf",centlo[i],centhi[i]);
      PsiMOddFinal[i] = new TH1F(moddfinalname,moddfinaltitle,100,-TMath::Pi()-.392699,TMath::Pi()+.392699);
      PsiMOddFinal[i]->GetXaxis()->SetTitle("EP Angle (radians)");


/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////
      //For Resolution of V1 Even
      psioneevenres->cd();
      sprintf(res4name,"TRPMinusTRM_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res4title,"First Order EP resolution TRPMinusTRM %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRM[i]= new TProfile(res4name,res4title,1,0,1);

      sprintf(res5name,"TRMMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res5title,"First Order EP resolution TRMMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRC[i]= new TProfile(res5name,res5title,1,0,1);

      sprintf(res6name,"TRPMinusTRC_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(res6title,"First Order EP resolution TRPMinusTRC %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRC[i]= new TProfile(res6name,res6title,1,0,1);


      //For Resolution of V1 Odd
      psioneoddres->cd();
      sprintf(v1oddres1name,"TRPMinusTRMOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres1title,"First Order EP resolution TRPMinusTRMOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRMOdd[i]= new TProfile(v1oddres1name,v1oddres1title,1,0,1);

      sprintf(v1oddres2name,"TRMMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres2title,"First Order EP resolution TRMMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRMMinusTRCOdd[i]= new TProfile(v1oddres2name,v1oddres2title,1,0,1);

      sprintf(v1oddres3name,"TRPMinusTRCOdd_EPResolution_%1.0lfto%1.0lf",centlo[i],centhi[i]);
      sprintf(v1oddres3title,"First Order EP resolution TRPMinusTRCOdd %1.0lf-%1.0lf %%",centlo[i],centhi[i]);
      TRPMinusTRCOdd[i]= new TProfile(v1oddres3name,v1oddres3title,1,0,1);



     }//end of centrality loop
}//end of initialize function

void FillPTStats(){

//Whole Tracker
ptavwhole[0]=0.943988;
ptavwhole[1]=0.954602;
ptavwhole[2]=0.955307;
ptavwhole[3]=0.949763;
ptavwhole[4]=0.939882;
 
pt2avwhole[0]=1.20194;
pt2avwhole[1]=1.23434;
pt2avwhole[2]=1.2424;
pt2avwhole[3]=1.23566;
pt2avwhole[4]=1.22399;
 
//Positive Tracker
ptavpos[0]=0.951766;
ptavpos[1]=0.964196;
ptavpos[2]=0.965113;
ptavpos[3]=0.961198;
ptavpos[4]=0.951578;
 
pt2avpos[0]=1.22045;
pt2avpos[1]=1.25792;
pt2avpos[2]=1.26781;
pt2avpos[3]=1.26375;
pt2avpos[4]=1.25626;
 
//Negative Tracker
ptavneg[0]=0.936896;
ptavneg[1]=0.946029;
ptavneg[2]=0.946591;
ptavneg[3]=0.939706;
ptavneg[4]=0.929512;
 
pt2avneg[0]=1.18506;
pt2avneg[1]=1.21326;
pt2avneg[2]=1.21981;
pt2avneg[3]=1.21096;
pt2avneg[4]=1.19538;
 
//Mid Tracker
ptavmid[0]=0.777236;
ptavmid[1]=0.78169;
ptavmid[2]=0.779461;
ptavmid[3]=0.772531;
ptavmid[4]=0.76186;
 
pt2avmid[0]=0.865594;
pt2avmid[1]=0.880871;
pt2avmid[2]=0.881363;
pt2avmid[3]=0.875955;
pt2avmid[4]=0.85338;
 

  }//end of fillptstats function



void FlowAnalysis(){
  for (Int_t i=0;i<NumberOfEvents;i++)
    {
      if ( !(i%10000) ) cout << " 1st round, event # " << i << " / " << NumberOfEvents << endl;

      chain2->GetEntry(i);//grab the ith event

      //Grab the Track Leaves
      NumTracks= (TLeaf*) chain2->GetLeaf("nTracks");
      TrackMom= (TLeaf*) chain2->GetLeaf("pt");
      TrackPhi= (TLeaf*) chain2->GetLeaf("phi");
      TrackEta= (TLeaf*) chain2->GetLeaf("eta");

      //Grab the Centrality Leaves
      CENTRAL= (TLeaf*) chain2->GetLeaf("bin");
      Centrality= CENTRAL->GetValue();
      if (Centrality>19) continue; //we dont care about any centrality greater than 60%


      for (int q=0;q<nCent;q++)
        {
          //v1 Even
          X_wholetracker[q]=0.;
          Y_wholetracker[q]=0.;
          X_postracker[q]=0.;
          Y_postracker[q]=0.;
          X_negtracker[q]=0.;
          Y_negtracker[q]=0.;
          X_midtracker[q]=0.;
          Y_midtracker[q]=0.;

          //v1 odd
          X_wholeoddtracker[q]=0.;
          Y_wholeoddtracker[q]=0.;
          X_posoddtracker[q]=0.;
          Y_posoddtracker[q]=0.;
          X_negoddtracker[q]=0.;
          Y_negoddtracker[q]=0.;
          X_midoddtracker[q]=0.;
          Y_midoddtracker[q]=0.;
        }

      NumberOfHits= NumTracks->GetValue();
      for (Int_t ii=0;ii<NumberOfHits;ii++)
        {
          pT=0.;
          phi=0.;
          eta=0.;
          pT=TrackMom->GetValue(ii);
          phi=TrackPhi->GetValue(ii);
          eta=TrackEta->GetValue(ii);
          if(pT<0)
            {
              continue;
            }
          for (Int_t c=0;c<nCent;c++)
            {
              if ( (Centrality*2.5) > centhi[c] ) continue;
              if ( (Centrality*2.5) < centlo[c] ) continue;
              if(eta>=1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_postracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_postracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholeoddtracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_posoddtracker[c]+=cos(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                  Y_posoddtracker[c]+=sin(phi)*(pT-(pt2avpos[c]/ptavpos[c]));
                }
              else if(eta<=-1.4)
                {
                  X_wholetracker[c]+=cos(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  Y_wholetracker[c]+=sin(phi)*(pT-(pt2avwhole[c]/ptavwhole[c]));
                  X_negtracker[c]+=cos(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  Y_negtracker[c]+=sin(phi)*(pT-(pt2avneg[c]/ptavneg[c]));
                  //v1 odd
                  X_wholeoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  Y_wholeoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avwhole[c]/ptavwhole[c])));
                  X_negoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                  Y_negoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avneg[c]/ptavneg[c])));
                }
              else if(eta<=0.6 && eta>0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midoddtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                }
              else if(eta>=-0.6 && eta<0)
                {
                  X_midtracker[c]+=cos(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  Y_midtracker[c]+=sin(phi)*(pT-(pt2avmid[c]/ptavmid[c]));
                  //v1 odd
                  X_midoddtracker[c]+=cos(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                  Y_midoddtracker[c]+=sin(phi)*(-1.0*(pT-(pt2avmid[c]/ptavmid[c])));
                }
            }//end of loop over centrality classes
        }//end of loop over tracks


      //Time to fill the appropriate histograms, this will be <X> <Y>
      for (Int_t c=0;c<nCent;c++)
        {
          if ( (Centrality*2.5) > centhi[c] ) continue;
          if ( (Centrality*2.5) < centlo[c] ) continue;

          //V1 even
          //Whole Tracker
          EPwholetracker=(1./1.)*atan2(Y_wholetracker[c],X_wholetracker[c]);
          if (EPwholetracker>(pi)) EPwholetracker=(EPwholetracker-(TMath::TwoPi()));
          if (EPwholetracker<(-1.0*(pi))) EPwholetracker=(EPwholetracker+(TMath::TwoPi()));
          PsiEvenRaw[c]->Fill(EPwholetracker);


          //Pos Tracker
          EPpostracker=(1./1.)*atan2(Y_postracker[c],X_postracker[c]);
          if (EPpostracker>(pi)) EPpostracker=(EPpostracker-(TMath::TwoPi()));
          if (EPpostracker<(-1.0*(pi))) EPpostracker=(EPpostracker+(TMath::TwoPi()));
          PsiPEvenRaw[c]->Fill(EPpostracker);

          //neg Tracker
          EPnegtracker=(1./1.)*atan2(Y_negtracker[c],X_negtracker[c]);
          if (EPnegtracker>(pi)) EPnegtracker=(EPnegtracker-(TMath::TwoPi()));
          if (EPnegtracker<(-1.0*(pi))) EPnegtracker=(EPnegtracker+(TMath::TwoPi()));
          PsiNEvenRaw[c]->Fill(EPnegtracker);


          //mid Tracker
          EPmidtracker=(1./1.)*atan2(Y_midtracker[c],X_midtracker[c]);
          if (EPmidtracker>(pi)) EPmidtracker=(EPmidtracker-(TMath::TwoPi()));
          if (EPmidtracker<(-1.0*(pi))) EPmidtracker=(EPmidtracker+(TMath::TwoPi()));
          PsiMEvenRaw[c]->Fill(EPmidtracker);

          //V1 odd
          //Whole Tracker
          EPwholeoddtracker=(1./1.)*atan2(Y_wholeoddtracker[c],X_wholeoddtracker[c]);
          if (EPwholeoddtracker>(pi)) EPwholeoddtracker=(EPwholeoddtracker-(TMath::TwoPi()));
          if (EPwholeoddtracker<(-1.0*(pi))) EPwholeoddtracker=(EPwholeoddtracker+(TMath::TwoPi()));
          PsiOddRaw[c]->Fill(EPwholeoddtracker);


          //Pos Tracker
          EPposoddtracker=(1./1.)*atan2(Y_posoddtracker[c],X_posoddtracker[c]);
          if (EPposoddtracker>(pi)) EPposoddtracker=(EPposoddtracker-(TMath::TwoPi()));
          if (EPposoddtracker<(-1.0*(pi))) EPposoddtracker=(EPposoddtracker+(TMath::TwoPi()));
          PsiPOddRaw[c]->Fill(EPposoddtracker);   

          //neg Tracker
          EPnegoddtracker=(1./1.)*atan2(Y_negoddtracker[c],X_negoddtracker[c]);
          if (EPnegoddtracker>(pi)) EPnegoddtracker=(EPnegoddtracker-(TMath::TwoPi()));
          if (EPnegoddtracker<(-1.0*(pi))) EPnegoddtracker=(EPnegoddtracker+(TMath::TwoPi()));
          PsiNOddRaw[c]->Fill(EPnegoddtracker);


          //mid Tracker
          EPmidoddtracker=(1./1.)*atan2(Y_midoddtracker[c],X_midoddtracker[c]);
          if (EPmidoddtracker>(pi)) EPmidoddtracker=(EPmidoddtracker-(TMath::TwoPi()));
          if (EPmidoddtracker<(-1.0*(pi))) EPmidoddtracker=(EPmidoddtracker+(TMath::TwoPi()));
          PsiMOddRaw[c]->Fill(EPmidoddtracker);

          //Zero the angular correction variables

          //v1 even stuff
          AngularCorrectionWholeTracker=0.;EPfinalwholetracker=0.;
          AngularCorrectionPosTracker=0.;EPfinalpostracker=0.;
          AngularCorrectionNegTracker=0.;EPfinalnegtracker=0.;
          AngularCorrectionMidTracker=0.;EPfinalmidtracker=0.;

          //v1 odd stuff
          AngularCorrectionWholeOddTracker=0.;EPfinalwholeoddtracker=0.;
          AngularCorrectionPosOddTracker=0.;EPfinalposoddtracker=0.;
          AngularCorrectionNegOddTracker=0.;EPfinalnegoddtracker=0.;
          AngularCorrectionMidOddTracker=0.;EPfinalmidoddtracker=0.;

          //Compute Angular Corrections
          for (Int_t k=1;k<(jMax+1);k++)
            {
              //v1 even
              //Whole Tracker
              AngularCorrectionWholeTracker+=((2./k)*(((-SineWholeTracker[c][k-1])*(cos(k*EPwholetracker)))+((CosineWholeTracker[c][k-1])*(sin(k*EPwholetracker)))));

              //Pos Tracker
              AngularCorrectionPosTracker+=((2./k)*(((-SinePosTracker[c][k-1])*(cos(k*EPpostracker)))+((CosinePosTracker[c][k-1])*(sin(k*EPpostracker)))));


              //Neg Tracker
              AngularCorrectionNegTracker+=((2./k)*(((-SineNegTracker[c][k-1])*(cos(k*EPnegtracker)))+((CosineNegTracker[c][k-1])*(sin(k*EPnegtracker)))));

              //Mid Tracker
              AngularCorrectionMidTracker+=((2./k)*(((-SineMidTracker[c][k-1])*(cos(k*EPmidtracker)))+((CosineMidTracker[c][k-1])*(sin(k*EPmidtracker)))));

              //v1 odd
              //Whole Tracker
              AngularCorrectionWholeOddTracker+=((2./k)*(((-SineWholeOddTracker[c][k-1])*(cos(k*EPwholeoddtracker)))+((CosineWholeOddTracker[c][k-1])*(sin(k*EPwholeoddtracker)))));

              //Pos Tracker
              AngularCorrectionPosOddTracker+=((2./k)*(((-SinePosOddTracker[c][k-1])*(cos(k*EPposoddtracker)))+((CosinePosOddTracker[c][k-1])*(sin(k*EPposoddtracker)))));


              //Neg Tracker
              AngularCorrectionNegOddTracker+=((2./k)*(((-SineNegOddTracker[c][k-1])*(cos(k*EPnegoddtracker)))+((CosineNegOddTracker[c][k-1])*(sin(k*EPnegoddtracker)))));

              //Mid Tracker
              AngularCorrectionMidOddTracker+=((2./k)*(((-SineMidOddTracker[c][k-1])*(cos(k*EPmidoddtracker)))+((CosineMidOddTracker[c][k-1])*(sin(k*EPmidoddtracker)))));


            }//end of angular correction calculation


          //Add the final Corrections to the Event Plane
          //and store it and do the flow measurement with it


          //Tracker

          //v1 even
          //Whole Tracker
          EPfinalwholetracker=EPwholetracker+AngularCorrectionWholeTracker;
          if (EPfinalwholetracker>(pi)) EPfinalwholetracker=(EPfinalwholetracker-(TMath::TwoPi()));
          if (EPfinalwholetracker<(-1.0*(pi))) EPfinalwholetracker=(EPfinalwholetracker+(TMath::TwoPi()));
          PsiEvenFinal[c]->Fill(EPfinalwholetracker);

          //Pos Tracker
          EPfinalpostracker=EPpostracker+AngularCorrectionPosTracker;
          if (EPfinalpostracker>(pi)) EPfinalpostracker=(EPfinalpostracker-(TMath::TwoPi()));
          if (EPfinalpostracker<(-1.0*(pi))) EPfinalpostracker=(EPfinalpostracker+(TMath::TwoPi()));
          PsiPEvenFinal[c]->Fill(EPfinalpostracker);

          //Neg Tracker
          EPfinalnegtracker=EPnegtracker+AngularCorrectionNegTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegtracker>(pi)) EPfinalnegtracker=(EPfinalnegtracker-(TMath::TwoPi()));
          if (EPfinalnegtracker<(-1.0*(pi))) EPfinalnegtracker=(EPfinalnegtracker+(TMath::TwoPi()));
          PsiNEvenFinal[c]->Fill(EPfinalnegtracker);


          //Mid Tracker
          EPfinalmidtracker=EPmidtracker+AngularCorrectionMidTracker;
          if (EPfinalmidtracker>(pi)) EPfinalmidtracker=(EPfinalmidtracker-(TMath::TwoPi()));
          if (EPfinalmidtracker<(-1.0*(pi))) EPfinalmidtracker=(EPfinalmidtracker+(TMath::TwoPi()));
          PsiMEvenFinal[c]->Fill(EPfinalmidtracker);

          //v1 odd
          //Whole Tracker
          EPfinalwholeoddtracker=EPwholeoddtracker+AngularCorrectionWholeOddTracker;
          if (EPfinalwholeoddtracker>(pi)) EPfinalwholeoddtracker=(EPfinalwholeoddtracker-(TMath::TwoPi()));
          if (EPfinalwholeoddtracker<(-1.0*(pi))) EPfinalwholeoddtracker=(EPfinalwholeoddtracker+(TMath::TwoPi()));
          PsiOddFinal[c]->Fill(EPfinalwholeoddtracker);

          //Pos Tracker
          EPfinalposoddtracker=EPposoddtracker+AngularCorrectionPosOddTracker;
          if (EPfinalposoddtracker>(pi)) EPfinalposoddtracker=(EPfinalposoddtracker-(TMath::TwoPi()));
          if (EPfinalposoddtracker<(-1.0*(pi))) EPfinalposoddtracker=(EPfinalposoddtracker+(TMath::TwoPi()));
          PsiPOddFinal[c]->Fill(EPfinalposoddtracker);


          //Neg Tracker
          EPfinalnegoddtracker=EPnegoddtracker+AngularCorrectionNegOddTracker;
          //if(c==2) std::cout<<EPfinalnegtracker<<std::endl;
          if (EPfinalnegoddtracker>(pi)) EPfinalnegoddtracker=(EPfinalnegoddtracker-(TMath::TwoPi()));
          if (EPfinalnegoddtracker<(-1.0*(pi))) EPfinalnegoddtracker=(EPfinalnegoddtracker+(TMath::TwoPi()));
          PsiNOddFinal[c]->Fill(EPfinalnegoddtracker);


          //Mid Tracker
          EPfinalmidoddtracker=EPmidoddtracker+AngularCorrectionMidOddTracker;
          if (EPfinalmidoddtracker>(pi)) EPfinalmidoddtracker=(EPfinalmidoddtracker-(TMath::TwoPi()));
          if (EPfinalmidoddtracker<(-1.0*(pi))) EPfinalmidoddtracker=(EPfinalmidoddtracker+(TMath::TwoPi()));
          PsiMOddFinal[c]->Fill(EPfinalmidoddtracker);


          //Resolutions
          //Even v1
          TRPMinusTRM[c]->Fill(0,cos(EPfinalpostracker-EPfinalnegtracker));
          TRMMinusTRC[c]->Fill(0,cos(EPfinalnegtracker-EPfinalmidtracker));
          TRPMinusTRC[c]->Fill(0,cos(EPfinalpostracker-EPfinalmidtracker));
          //Odd V1
          TRPMinusTRMOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalnegoddtracker));
          TRMMinusTRCOdd[c]->Fill(0,cos(EPfinalnegoddtracker-EPfinalmidoddtracker));
          TRPMinusTRCOdd[c]->Fill(0,cos(EPfinalposoddtracker-EPfinalmidoddtracker));



          //Loop again over tracks to find the flow
          NumberOfHits= NumTracks->GetValue();
          for (Int_t ii=0;ii<NumberOfHits;ii++)
            {
              pT=0.;
              phi=0.;
              eta=0.;
              pT=TrackMom->GetValue(ii);
              phi=TrackPhi->GetValue(ii);
              eta=TrackEta->GetValue(ii);
              if(pT<0)
                {
                  continue;
                }
              //              std::cout<<pT<<" "<<eta<<" "<<phi<<std::endl;
              if(fabs(eta)<0.6 && pT>0.4)
                {
                  V1EtaOdd[c]->Fill(eta,cos(phi-EPfinalwholeoddtracker));
                  if(pT<=3.5) V1EtaEven[c]->Fill(eta,cos(phi-EPfinalwholetracker));
                  V1PtOdd[c]->Fill(pT,cos(phi-EPfinalwholeoddtracker));
                  PTCenters[c]->Fill(pT,pT);
                  V1PtEven[c]->Fill(pT,cos(phi-EPfinalwholetracker));
                }
            }//end of loop over tracks
        }//End of loop over centralities
    }//End of loop over events
  myFile->Write();
}//End of Flow Analysis Function

void FillAngularCorrections(){
//V1 Even
//Whole Tracker
CosineWholeTracker[0][0]=-0.203545;
CosineWholeTracker[1][0]=-0.174002;
CosineWholeTracker[2][0]=-0.141867;
CosineWholeTracker[3][0]=-0.117706;
CosineWholeTracker[4][0]=-0.108733;
 
SineWholeTracker[0][0]=-0.636805;
SineWholeTracker[1][0]=-0.557461;
SineWholeTracker[2][0]=-0.480306;
SineWholeTracker[3][0]=-0.385893;
SineWholeTracker[4][0]=-0.333856;
 
CosineWholeTracker[0][1]=-0.265369;
CosineWholeTracker[1][1]=-0.191377;
CosineWholeTracker[2][1]=-0.139319;
CosineWholeTracker[3][1]=-0.103047;
CosineWholeTracker[4][1]=-0.0846704;
 
SineWholeTracker[0][1]=0.168046;
SineWholeTracker[1][1]=0.126276;
SineWholeTracker[2][1]=0.0845997;
SineWholeTracker[3][1]=0.0471441;
SineWholeTracker[4][1]=0.0322446;
 
CosineWholeTracker[0][2]=0.0845535;
CosineWholeTracker[1][2]=0.0302359;
CosineWholeTracker[2][2]=0.0162545;
CosineWholeTracker[3][2]=0.0169341;
CosineWholeTracker[4][2]=0.00565425;
 
SineWholeTracker[0][2]=0.0881367;
SineWholeTracker[1][2]=0.0624867;
SineWholeTracker[2][2]=0.032438;
SineWholeTracker[3][2]=0.0192473;
SineWholeTracker[4][2]=0.0334513;
 
CosineWholeTracker[0][3]=0.0255253;
CosineWholeTracker[1][3]=0.0264386;
CosineWholeTracker[2][3]=0.0135882;
CosineWholeTracker[3][3]=0.0196083;
CosineWholeTracker[4][3]=0.0261779;
 
SineWholeTracker[0][3]=-0.0422018;
SineWholeTracker[1][3]=-0.000576994;
SineWholeTracker[2][3]=-0.00777631;
SineWholeTracker[3][3]=-0.0135385;
SineWholeTracker[4][3]=-0.00388122;
 
CosineWholeTracker[0][4]=-0.0267831;
CosineWholeTracker[1][4]=0.00521582;
CosineWholeTracker[2][4]=-0.0156849;
CosineWholeTracker[3][4]=-0.00707898;
CosineWholeTracker[4][4]=0.011391;
 
SineWholeTracker[0][4]=-0.0213179;
SineWholeTracker[1][4]=-0.00902305;
SineWholeTracker[2][4]=-0.000753956;
SineWholeTracker[3][4]=0.000971016;
SineWholeTracker[4][4]=0.00906519;
 
CosineWholeTracker[0][5]=-0.00819939;
CosineWholeTracker[1][5]=0.00124946;
CosineWholeTracker[2][5]=-0.00479356;
CosineWholeTracker[3][5]=0.012576;
CosineWholeTracker[4][5]=0.00175364;
 
SineWholeTracker[0][5]=0.016036;
SineWholeTracker[1][5]=-0.00933159;
SineWholeTracker[2][5]=0.0044605;
SineWholeTracker[3][5]=0.0162005;
SineWholeTracker[4][5]=-0.0277049;
 
CosineWholeTracker[0][6]=-0.00653037;
CosineWholeTracker[1][6]=-0.0241775;
CosineWholeTracker[2][6]=0.0185671;
CosineWholeTracker[3][6]=0.002018;
CosineWholeTracker[4][6]=-0.0232679;
 
SineWholeTracker[0][6]=0.0120729;
SineWholeTracker[1][6]=-0.0108217;
SineWholeTracker[2][6]=-0.00563261;
SineWholeTracker[3][6]=-0.0171402;
SineWholeTracker[4][6]=-0.0109186;
 
CosineWholeTracker[0][7]=0.0185774;
CosineWholeTracker[1][7]=0.0108307;
CosineWholeTracker[2][7]=-0.0102774;
CosineWholeTracker[3][7]=0.000996292;
CosineWholeTracker[4][7]=-0.0299184;
 
SineWholeTracker[0][7]=-0.0148431;
SineWholeTracker[1][7]=-0.00360126;
SineWholeTracker[2][7]=-0.000520016;
SineWholeTracker[3][7]=-0.0148421;
SineWholeTracker[4][7]=0.00847014;
 
CosineWholeTracker[0][8]=-0.0101676;
CosineWholeTracker[1][8]=-0.0106248;
CosineWholeTracker[2][8]=0.00628315;
CosineWholeTracker[3][8]=-0.0141079;
CosineWholeTracker[4][8]=0.00498501;
 
SineWholeTracker[0][8]=-0.0216189;
SineWholeTracker[1][8]=0.0122808;
SineWholeTracker[2][8]=-0.00474273;
SineWholeTracker[3][8]=0.0020995;
SineWholeTracker[4][8]=0.0347915;
 
CosineWholeTracker[0][9]=-0.00596224;
CosineWholeTracker[1][9]=-0.000974544;
CosineWholeTracker[2][9]=-0.0080407;
CosineWholeTracker[3][9]=-0.00627268;
CosineWholeTracker[4][9]=0.0105382;
 
SineWholeTracker[0][9]=0.00658603;
SineWholeTracker[1][9]=0.0157442;
SineWholeTracker[2][9]=0.00603073;
SineWholeTracker[3][9]=0.016718;
SineWholeTracker[4][9]=0.00778283;
 
 
//Pos Tracker
CosinePosTracker[0][0]=-0.0334198;
CosinePosTracker[1][0]=-0.0363829;
CosinePosTracker[2][0]=-0.0220613;
CosinePosTracker[3][0]=-0.0236168;
CosinePosTracker[4][0]=-0.0198996;
 
SinePosTracker[0][0]=-0.462066;
SinePosTracker[1][0]=-0.427649;
SinePosTracker[2][0]=-0.355839;
SinePosTracker[3][0]=-0.271715;
SinePosTracker[4][0]=-0.253383;
 
CosinePosTracker[0][1]=-0.163012;
CosinePosTracker[1][1]=-0.12366;
CosinePosTracker[2][1]=-0.0686052;
CosinePosTracker[3][1]=-0.0305228;
CosinePosTracker[4][1]=-0.0442217;
 
SinePosTracker[0][1]=-0.00401646;
SinePosTracker[1][1]=0.0135757;
SinePosTracker[2][1]=0.0179178;
SinePosTracker[3][1]=-0.00371518;
SinePosTracker[4][1]=0.0141985;
 
CosinePosTracker[0][2]=-0.0147721;
CosinePosTracker[1][2]=-0.0185972;
CosinePosTracker[2][2]=0.00862312;
CosinePosTracker[3][2]=0.00363696;
CosinePosTracker[4][2]=-0.0129418;
 
SinePosTracker[0][2]=0.0419829;
SinePosTracker[1][2]=0.0372768;
SinePosTracker[2][2]=0.0260491;
SinePosTracker[3][2]=0.0192725;
SinePosTracker[4][2]=0.0263591;
 
CosinePosTracker[0][3]=0.00786192;
CosinePosTracker[1][3]=0.0104506;
CosinePosTracker[2][3]=0.0083491;
CosinePosTracker[3][3]=0.0134301;
CosinePosTracker[4][3]=0.0152183;
 
SinePosTracker[0][3]=0.0159307;
SinePosTracker[1][3]=0.0326436;
SinePosTracker[2][3]=-0.00150912;
SinePosTracker[3][3]=-0.00993719;
SinePosTracker[4][3]=-0.0295571;
 
CosinePosTracker[0][4]=0.0154964;
CosinePosTracker[1][4]=0.00600717;
CosinePosTracker[2][4]=-0.0131551;
CosinePosTracker[3][4]=0.00998828;
CosinePosTracker[4][4]=-0.00861319;
 
SinePosTracker[0][4]=0.00439571;
SinePosTracker[1][4]=0.00396168;
SinePosTracker[2][4]=0.0145774;
SinePosTracker[3][4]=-0.0138344;
SinePosTracker[4][4]=0.00845772;
 
CosinePosTracker[0][5]=0.00234728;
CosinePosTracker[1][5]=0.00224064;
CosinePosTracker[2][5]=0.0128333;
CosinePosTracker[3][5]=0.0173756;
CosinePosTracker[4][5]=0.0299181;
 
SinePosTracker[0][5]=-0.00996679;
SinePosTracker[1][5]=-0.00969263;
SinePosTracker[2][5]=0.00917262;
SinePosTracker[3][5]=-0.0011201;
SinePosTracker[4][5]=0.00434665;
 
CosinePosTracker[0][6]=0.000553744;
CosinePosTracker[1][6]=0.00652216;
CosinePosTracker[2][6]=-0.0121914;
CosinePosTracker[3][6]=-0.00427417;
CosinePosTracker[4][6]=0.00877609;
 
SinePosTracker[0][6]=-0.000528335;
SinePosTracker[1][6]=-0.011564;
SinePosTracker[2][6]=0.00171401;
SinePosTracker[3][6]=0.00527463;
SinePosTracker[4][6]=-0.000208074;
 
CosinePosTracker[0][7]=0.000215819;
CosinePosTracker[1][7]=-0.00186457;
CosinePosTracker[2][7]=0.0259379;
CosinePosTracker[3][7]=0.00726873;
CosinePosTracker[4][7]=-0.000883976;
 
SinePosTracker[0][7]=-0.0102481;
SinePosTracker[1][7]=-0.0172504;
SinePosTracker[2][7]=-0.00561162;
SinePosTracker[3][7]=0.000559439;
SinePosTracker[4][7]=-0.00497904;
 
CosinePosTracker[0][8]=0.0174909;
CosinePosTracker[1][8]=0.00476253;
CosinePosTracker[2][8]=0.00784163;
CosinePosTracker[3][8]=-0.00363466;
CosinePosTracker[4][8]=-0.00586158;
 
SinePosTracker[0][8]=0.0104193;
SinePosTracker[1][8]=-0.00509534;
SinePosTracker[2][8]=-0.0105037;
SinePosTracker[3][8]=0.000609921;
SinePosTracker[4][8]=-0.000766677;
 
CosinePosTracker[0][9]=0.0083222;
CosinePosTracker[1][9]=-6.88714e-05;
CosinePosTracker[2][9]=-0.0164694;
CosinePosTracker[3][9]=-0.0105454;
CosinePosTracker[4][9]=0.0151913;
 
SinePosTracker[0][9]=-0.000655756;
SinePosTracker[1][9]=-0.00645638;
SinePosTracker[2][9]=-0.00590236;
SinePosTracker[3][9]=-0.000987958;
SinePosTracker[4][9]=-0.0103287;
 
 
//Neg Tracker
CosineNegTracker[0][0]=-0.257414;
CosineNegTracker[1][0]=-0.209727;
CosineNegTracker[2][0]=-0.16963;
CosineNegTracker[3][0]=-0.126918;
CosineNegTracker[4][0]=-0.116838;
 
SineNegTracker[0][0]=-0.544083;
SineNegTracker[1][0]=-0.459068;
SineNegTracker[2][0]=-0.387657;
SineNegTracker[3][0]=-0.323938;
SineNegTracker[4][0]=-0.264962;
 
CosineNegTracker[0][1]=-0.154567;
CosineNegTracker[1][1]=-0.127242;
CosineNegTracker[2][1]=-0.0785734;
CosineNegTracker[3][1]=-0.0694756;
CosineNegTracker[4][1]=-0.0305506;
 
SineNegTracker[0][1]=0.186477;
SineNegTracker[1][1]=0.118292;
SineNegTracker[2][1]=0.0809586;
SineNegTracker[3][1]=0.0294876;
SineNegTracker[4][1]=0.0267047;
 
CosineNegTracker[0][2]=0.0591154;
CosineNegTracker[1][2]=0.032288;
CosineNegTracker[2][2]=0.0177841;
CosineNegTracker[3][2]=-0.00648163;
CosineNegTracker[4][2]=-0.00305189;
 
SineNegTracker[0][2]=0.0390209;
SineNegTracker[1][2]=0.0262543;
SineNegTracker[2][2]=-0.00389968;
SineNegTracker[3][2]=0.00799938;
SineNegTracker[4][2]=0.0106961;
 
CosineNegTracker[0][3]=0.0260213;
CosineNegTracker[1][3]=0.00379824;
CosineNegTracker[2][3]=-0.00625075;
CosineNegTracker[3][3]=-0.000552707;
CosineNegTracker[4][3]=0.0114154;
 
SineNegTracker[0][3]=-0.0100406;
SineNegTracker[1][3]=-0.0204619;
SineNegTracker[2][3]=0.00643397;
SineNegTracker[3][3]=-0.00454366;
SineNegTracker[4][3]=-0.0143757;
 
CosineNegTracker[0][4]=-0.00741013;
CosineNegTracker[1][4]=-0.00592319;
CosineNegTracker[2][4]=0.00430554;
CosineNegTracker[3][4]=-0.00970173;
CosineNegTracker[4][4]=-0.0208621;
 
SineNegTracker[0][4]=-0.0268432;
SineNegTracker[1][4]=-0.00896421;
SineNegTracker[2][4]=0.00491064;
SineNegTracker[3][4]=0.00517035;
SineNegTracker[4][4]=-0.0183688;
 
CosineNegTracker[0][5]=-0.00670966;
CosineNegTracker[1][5]=-0.0230799;
CosineNegTracker[2][5]=-0.00284914;
CosineNegTracker[3][5]=0.00250473;
CosineNegTracker[4][5]=-0.00481755;
 
SineNegTracker[0][5]=0.0154761;
SineNegTracker[1][5]=0.000335506;
SineNegTracker[2][5]=-0.00732461;
SineNegTracker[3][5]=0.0120671;
SineNegTracker[4][5]=0.0211395;
 
CosineNegTracker[0][6]=0.00547548;
CosineNegTracker[1][6]=0.00355598;
CosineNegTracker[2][6]=0.00784049;
CosineNegTracker[3][6]=-0.000351545;
CosineNegTracker[4][6]=0.0158744;
 
SineNegTracker[0][6]=-0.0110205;
SineNegTracker[1][6]=0.0245036;
SineNegTracker[2][6]=0.0155756;
SineNegTracker[3][6]=0.0115944;
SineNegTracker[4][6]=-0.00769879;
 
CosineNegTracker[0][7]=-0.000361322;
CosineNegTracker[1][7]=-0.00389915;
CosineNegTracker[2][7]=-0.000281207;
CosineNegTracker[3][7]=-0.00422934;
CosineNegTracker[4][7]=0.00935203;
 
SineNegTracker[0][7]=-0.0114621;
SineNegTracker[1][7]=-0.0129282;
SineNegTracker[2][7]=0.00284698;
SineNegTracker[3][7]=-0.0176179;
SineNegTracker[4][7]=-0.0132533;
 
CosineNegTracker[0][8]=-0.0105302;
CosineNegTracker[1][8]=0.00650437;
CosineNegTracker[2][8]=-0.00202895;
CosineNegTracker[3][8]=-0.00869404;
CosineNegTracker[4][8]=0.00465813;
 
SineNegTracker[0][8]=0.00462559;
SineNegTracker[1][8]=0.0112776;
SineNegTracker[2][8]=0.00719767;
SineNegTracker[3][8]=-0.00589438;
SineNegTracker[4][8]=0.00392315;
 
CosineNegTracker[0][9]=0.00715906;
CosineNegTracker[1][9]=0.00336084;
CosineNegTracker[2][9]=0.00653852;
CosineNegTracker[3][9]=-0.0182451;
CosineNegTracker[4][9]=0.00321025;
 
SineNegTracker[0][9]=0.00564218;
SineNegTracker[1][9]=-0.00302691;
SineNegTracker[2][9]=0.00189628;
SineNegTracker[3][9]=0.0184726;
SineNegTracker[4][9]=0.0180733;
 
 
//Mid Tracker
CosineMidTracker[0][0]=-0.212868;
CosineMidTracker[1][0]=-0.181212;
CosineMidTracker[2][0]=-0.149333;
CosineMidTracker[3][0]=-0.138395;
CosineMidTracker[4][0]=-0.129936;
 
SineMidTracker[0][0]=-0.130426;
SineMidTracker[1][0]=-0.128192;
SineMidTracker[2][0]=-0.101047;
SineMidTracker[3][0]=-0.0867877;
SineMidTracker[4][0]=-0.0728465;
 
CosineMidTracker[0][1]=-0.00265525;
CosineMidTracker[1][1]=0.00858651;
CosineMidTracker[2][1]=0.0114209;
CosineMidTracker[3][1]=-0.00335703;
CosineMidTracker[4][1]=0.0111312;
 
SineMidTracker[0][1]=0.0185982;
SineMidTracker[1][1]=0.0158662;
SineMidTracker[2][1]=0.00738542;
SineMidTracker[3][1]=0.000135713;
SineMidTracker[4][1]=0.0287917;
 
CosineMidTracker[0][2]=-0.00759974;
CosineMidTracker[1][2]=-0.00627319;
CosineMidTracker[2][2]=-0.0144594;
CosineMidTracker[3][2]=-0.0109541;
CosineMidTracker[4][2]=-0.0144837;
 
SineMidTracker[0][2]=0.0224047;
SineMidTracker[1][2]=0.00499782;
SineMidTracker[2][2]=0.0116914;
SineMidTracker[3][2]=0.00210155;
SineMidTracker[4][2]=-0.00227619;
 
CosineMidTracker[0][3]=0.010094;
CosineMidTracker[1][3]=-0.00120482;
CosineMidTracker[2][3]=0.0160225;
CosineMidTracker[3][3]=0.00157861;
CosineMidTracker[4][3]=-0.00800565;
 
SineMidTracker[0][3]=0.0142649;
SineMidTracker[1][3]=-0.00929495;
SineMidTracker[2][3]=-0.000565141;
SineMidTracker[3][3]=-0.00853504;
SineMidTracker[4][3]=-0.0175409;
 
CosineMidTracker[0][4]=0.0210822;
CosineMidTracker[1][4]=-0.00968462;
CosineMidTracker[2][4]=-0.00710462;
CosineMidTracker[3][4]=-0.0163633;
CosineMidTracker[4][4]=0.00170709;
 
SineMidTracker[0][4]=-0.0110116;
SineMidTracker[1][4]=0.00585438;
SineMidTracker[2][4]=-0.0066275;
SineMidTracker[3][4]=0.0123084;
SineMidTracker[4][4]=0.0109242;
 
CosineMidTracker[0][5]=-0.00819206;
CosineMidTracker[1][5]=-0.00322476;
CosineMidTracker[2][5]=-0.00677891;
CosineMidTracker[3][5]=0.0105875;
CosineMidTracker[4][5]=-0.0164996;
 
SineMidTracker[0][5]=-0.00222131;
SineMidTracker[1][5]=0.00461052;
SineMidTracker[2][5]=0.00737585;
SineMidTracker[3][5]=0.0115928;
SineMidTracker[4][5]=0.0138868;
 
CosineMidTracker[0][6]=-0.0129909;
CosineMidTracker[1][6]=-0.00551212;
CosineMidTracker[2][6]=-0.00989142;
CosineMidTracker[3][6]=-0.00457318;
CosineMidTracker[4][6]=-0.00433995;
 
SineMidTracker[0][6]=0.00491175;
SineMidTracker[1][6]=-0.00517133;
SineMidTracker[2][6]=-0.00606934;
SineMidTracker[3][6]=-0.0111338;
SineMidTracker[4][6]=0.00102288;
 
CosineMidTracker[0][7]=-0.00156427;
CosineMidTracker[1][7]=0.00350198;
CosineMidTracker[2][7]=-0.00736311;
CosineMidTracker[3][7]=-0.0231091;
CosineMidTracker[4][7]=-0.00707871;
 
SineMidTracker[0][7]=-0.00751812;
SineMidTracker[1][7]=0.00706474;
SineMidTracker[2][7]=0.0318809;
SineMidTracker[3][7]=0.0265628;
SineMidTracker[4][7]=-0.00694884;
 
CosineMidTracker[0][8]=0.00408107;
CosineMidTracker[1][8]=-0.000399539;
CosineMidTracker[2][8]=0.0163474;
CosineMidTracker[3][8]=0.00818751;
CosineMidTracker[4][8]=0.00562558;
 
SineMidTracker[0][8]=0.00160721;
SineMidTracker[1][8]=0.0034307;
SineMidTracker[2][8]=8.50788e-05;
SineMidTracker[3][8]=0.017162;
SineMidTracker[4][8]=0.0244315;
 
CosineMidTracker[0][9]=-0.00450998;
CosineMidTracker[1][9]=-0.0187876;
CosineMidTracker[2][9]=-0.0247274;
CosineMidTracker[3][9]=-0.00605544;
CosineMidTracker[4][9]=0.00720056;
 
SineMidTracker[0][9]=-0.00604703;
SineMidTracker[1][9]=-0.00540948;
SineMidTracker[2][9]=-1.39829e-05;
SineMidTracker[3][9]=-0.00686926;
SineMidTracker[4][9]=-0.0038078;
 
//V1 Odd
//Whole Tracker
CosineWholeOddTracker[0][0]=0.1766;
CosineWholeOddTracker[1][0]=0.138076;
CosineWholeOddTracker[2][0]=0.107247;
CosineWholeOddTracker[3][0]=0.0686768;
CosineWholeOddTracker[4][0]=0.0627996;
 
SineWholeOddTracker[0][0]=0.0875275;
SineWholeOddTracker[1][0]=0.0562189;
SineWholeOddTracker[2][0]=0.055;
SineWholeOddTracker[3][0]=0.0478722;
SineWholeOddTracker[4][0]=0.00794807;
 
CosineWholeOddTracker[0][1]=-0.000614916;
CosineWholeOddTracker[1][1]=0.0104215;
CosineWholeOddTracker[2][1]=0.0288964;
CosineWholeOddTracker[3][1]=0.0122181;
CosineWholeOddTracker[4][1]=0.0237234;
 
SineWholeOddTracker[0][1]=0.0147806;
SineWholeOddTracker[1][1]=0.00427066;
SineWholeOddTracker[2][1]=0.00707577;
SineWholeOddTracker[3][1]=0.00475811;
SineWholeOddTracker[4][1]=0.0289328;
 
CosineWholeOddTracker[0][2]=-0.0139118;
CosineWholeOddTracker[1][2]=-0.00268663;
CosineWholeOddTracker[2][2]=-0.00290369;
CosineWholeOddTracker[3][2]=-0.017486;
CosineWholeOddTracker[4][2]=-0.0181473;
 
SineWholeOddTracker[0][2]=0.0117607;
SineWholeOddTracker[1][2]=0.00504812;
SineWholeOddTracker[2][2]=-0.0020124;
SineWholeOddTracker[3][2]=0.0154498;
SineWholeOddTracker[4][2]=-0.00579086;
 
CosineWholeOddTracker[0][3]=-0.0189569;
CosineWholeOddTracker[1][3]=-0.00408705;
CosineWholeOddTracker[2][3]=0.00458225;
CosineWholeOddTracker[3][3]=0.0085166;
CosineWholeOddTracker[4][3]=-0.00537506;
 
SineWholeOddTracker[0][3]=-0.0126827;
SineWholeOddTracker[1][3]=-0.00175937;
SineWholeOddTracker[2][3]=-0.0101073;
SineWholeOddTracker[3][3]=0.0102544;
SineWholeOddTracker[4][3]=-0.00957373;
 
CosineWholeOddTracker[0][4]=-0.0269568;
CosineWholeOddTracker[1][4]=-0.0234458;
CosineWholeOddTracker[2][4]=0.0145334;
CosineWholeOddTracker[3][4]=0.00981547;
CosineWholeOddTracker[4][4]=0.0182089;
 
SineWholeOddTracker[0][4]=0.00679262;
SineWholeOddTracker[1][4]=0.00390877;
SineWholeOddTracker[2][4]=0.00255921;
SineWholeOddTracker[3][4]=0.00343758;
SineWholeOddTracker[4][4]=-0.00661;
 
CosineWholeOddTracker[0][5]=0.00516467;
CosineWholeOddTracker[1][5]=0.0183826;
CosineWholeOddTracker[2][5]=0.00368176;
CosineWholeOddTracker[3][5]=-0.00321293;
CosineWholeOddTracker[4][5]=0.00270872;
 
SineWholeOddTracker[0][5]=0.00374003;
SineWholeOddTracker[1][5]=0.00407332;
SineWholeOddTracker[2][5]=0.00221997;
SineWholeOddTracker[3][5]=-0.0213347;
SineWholeOddTracker[4][5]=-0.0177307;
 
CosineWholeOddTracker[0][6]=-0.00585038;
CosineWholeOddTracker[1][6]=4.03663e-05;
CosineWholeOddTracker[2][6]=0.0154383;
CosineWholeOddTracker[3][6]=0.0115897;
CosineWholeOddTracker[4][6]=0.00922035;
 
SineWholeOddTracker[0][6]=-0.0133818;
SineWholeOddTracker[1][6]=0.00977412;
SineWholeOddTracker[2][6]=0.00127631;
SineWholeOddTracker[3][6]=-0.00280581;
SineWholeOddTracker[4][6]=0.00209191;
 
CosineWholeOddTracker[0][7]=0.00375671;
CosineWholeOddTracker[1][7]=0.0134866;
CosineWholeOddTracker[2][7]=0.00217413;
CosineWholeOddTracker[3][7]=0.00244767;
CosineWholeOddTracker[4][7]=-0.0118386;
 
SineWholeOddTracker[0][7]=-0.00123795;
SineWholeOddTracker[1][7]=-0.0233787;
SineWholeOddTracker[2][7]=-0.0109318;
SineWholeOddTracker[3][7]=-0.00881966;
SineWholeOddTracker[4][7]=0.00266443;
 
CosineWholeOddTracker[0][8]=-0.000285533;
CosineWholeOddTracker[1][8]=-0.00385834;
CosineWholeOddTracker[2][8]=-0.0144594;
CosineWholeOddTracker[3][8]=-0.0187186;
CosineWholeOddTracker[4][8]=0.00713985;
 
SineWholeOddTracker[0][8]=-0.00522986;
SineWholeOddTracker[1][8]=-0.0183968;
SineWholeOddTracker[2][8]=-0.00616201;
SineWholeOddTracker[3][8]=0.00572477;
SineWholeOddTracker[4][8]=0.00794018;
 
CosineWholeOddTracker[0][9]=0.0106749;
CosineWholeOddTracker[1][9]=-0.0113253;
CosineWholeOddTracker[2][9]=-0.0241472;
CosineWholeOddTracker[3][9]=0.00351927;
CosineWholeOddTracker[4][9]=0.00111875;
 
SineWholeOddTracker[0][9]=-0.0148231;
SineWholeOddTracker[1][9]=-0.00919838;
SineWholeOddTracker[2][9]=-0.0111518;
SineWholeOddTracker[3][9]=-0.00363432;
SineWholeOddTracker[4][9]=-0.0125406;
 
 
//Pos Tracker
CosinePosOddTracker[0][0]=-0.0334198;
CosinePosOddTracker[1][0]=-0.0363829;
CosinePosOddTracker[2][0]=-0.0220613;
CosinePosOddTracker[3][0]=-0.0236168;
CosinePosOddTracker[4][0]=-0.0198996;
 
SinePosOddTracker[0][0]=-0.462066;
SinePosOddTracker[1][0]=-0.427649;
SinePosOddTracker[2][0]=-0.355839;
SinePosOddTracker[3][0]=-0.271715;
SinePosOddTracker[4][0]=-0.253383;
 
CosinePosOddTracker[0][1]=-0.163012;
CosinePosOddTracker[1][1]=-0.12366;
CosinePosOddTracker[2][1]=-0.0686052;
CosinePosOddTracker[3][1]=-0.0305228;
CosinePosOddTracker[4][1]=-0.0442217;
 
SinePosOddTracker[0][1]=-0.00401646;
SinePosOddTracker[1][1]=0.0135757;
SinePosOddTracker[2][1]=0.0179178;
SinePosOddTracker[3][1]=-0.00371518;
SinePosOddTracker[4][1]=0.0141985;
 
CosinePosOddTracker[0][2]=-0.0147721;
CosinePosOddTracker[1][2]=-0.0185972;
CosinePosOddTracker[2][2]=0.00862312;
CosinePosOddTracker[3][2]=0.00363696;
CosinePosOddTracker[4][2]=-0.0129418;
 
SinePosOddTracker[0][2]=0.0419829;
SinePosOddTracker[1][2]=0.0372768;
SinePosOddTracker[2][2]=0.0260491;
SinePosOddTracker[3][2]=0.0192725;
SinePosOddTracker[4][2]=0.0263591;
 
CosinePosOddTracker[0][3]=0.00786192;
CosinePosOddTracker[1][3]=0.0104506;
CosinePosOddTracker[2][3]=0.0083491;
CosinePosOddTracker[3][3]=0.0134301;
CosinePosOddTracker[4][3]=0.0152183;
 
SinePosOddTracker[0][3]=0.0159307;
SinePosOddTracker[1][3]=0.0326436;
SinePosOddTracker[2][3]=-0.00150912;
SinePosOddTracker[3][3]=-0.00993719;
SinePosOddTracker[4][3]=-0.0295571;
 
CosinePosOddTracker[0][4]=0.0154964;
CosinePosOddTracker[1][4]=0.00600717;
CosinePosOddTracker[2][4]=-0.0131551;
CosinePosOddTracker[3][4]=0.00998828;
CosinePosOddTracker[4][4]=-0.00861319;
 
SinePosOddTracker[0][4]=0.00439571;
SinePosOddTracker[1][4]=0.00396168;
SinePosOddTracker[2][4]=0.0145774;
SinePosOddTracker[3][4]=-0.0138344;
SinePosOddTracker[4][4]=0.00845772;
 
CosinePosOddTracker[0][5]=0.00234728;
CosinePosOddTracker[1][5]=0.00224064;
CosinePosOddTracker[2][5]=0.0128333;
CosinePosOddTracker[3][5]=0.0173756;
CosinePosOddTracker[4][5]=0.0299181;
 
SinePosOddTracker[0][5]=-0.00996679;
SinePosOddTracker[1][5]=-0.00969263;
SinePosOddTracker[2][5]=0.00917262;
SinePosOddTracker[3][5]=-0.0011201;
SinePosOddTracker[4][5]=0.00434665;
 
CosinePosOddTracker[0][6]=0.000553744;
CosinePosOddTracker[1][6]=0.00652216;
CosinePosOddTracker[2][6]=-0.0121914;
CosinePosOddTracker[3][6]=-0.00427417;
CosinePosOddTracker[4][6]=0.00877609;
 
SinePosOddTracker[0][6]=-0.000528335;
SinePosOddTracker[1][6]=-0.011564;
SinePosOddTracker[2][6]=0.00171401;
SinePosOddTracker[3][6]=0.00527463;
SinePosOddTracker[4][6]=-0.000208074;
 
CosinePosOddTracker[0][7]=0.000215819;
CosinePosOddTracker[1][7]=-0.00186457;
CosinePosOddTracker[2][7]=0.0259379;
CosinePosOddTracker[3][7]=0.00726873;
CosinePosOddTracker[4][7]=-0.000883976;
 
SinePosOddTracker[0][7]=-0.0102481;
SinePosOddTracker[1][7]=-0.0172504;
SinePosOddTracker[2][7]=-0.00561162;
SinePosOddTracker[3][7]=0.000559439;
SinePosOddTracker[4][7]=-0.00497904;
 
CosinePosOddTracker[0][8]=0.0174909;
CosinePosOddTracker[1][8]=0.00476253;
CosinePosOddTracker[2][8]=0.00784163;
CosinePosOddTracker[3][8]=-0.00363466;
CosinePosOddTracker[4][8]=-0.00586158;
 
SinePosOddTracker[0][8]=0.0104193;
SinePosOddTracker[1][8]=-0.00509534;
SinePosOddTracker[2][8]=-0.0105037;
SinePosOddTracker[3][8]=0.000609921;
SinePosOddTracker[4][8]=-0.000766677;
 
CosinePosOddTracker[0][9]=0.0083222;
CosinePosOddTracker[1][9]=-6.88714e-05;
CosinePosOddTracker[2][9]=-0.0164694;
CosinePosOddTracker[3][9]=-0.0105454;
CosinePosOddTracker[4][9]=0.0151913;
 
SinePosOddTracker[0][9]=-0.000655756;
SinePosOddTracker[1][9]=-0.00645638;
SinePosOddTracker[2][9]=-0.00590236;
SinePosOddTracker[3][9]=-0.000987958;
SinePosOddTracker[4][9]=-0.0103287;
 
 
//Neg Tracker
CosineNegOddTracker[0][0]=0.257935;
CosineNegOddTracker[1][0]=0.210217;
CosineNegOddTracker[2][0]=0.170595;
CosineNegOddTracker[3][0]=0.127392;
CosineNegOddTracker[4][0]=0.119787;
 
SineNegOddTracker[0][0]=0.544083;
SineNegOddTracker[1][0]=0.459068;
SineNegOddTracker[2][0]=0.387657;
SineNegOddTracker[3][0]=0.323938;
SineNegOddTracker[4][0]=0.264962;
 
CosineNegOddTracker[0][1]=-0.154567;
CosineNegOddTracker[1][1]=-0.127242;
CosineNegOddTracker[2][1]=-0.0785734;
CosineNegOddTracker[3][1]=-0.0694756;
CosineNegOddTracker[4][1]=-0.0305506;
 
SineNegOddTracker[0][1]=0.186477;
SineNegOddTracker[1][1]=0.118292;
SineNegOddTracker[2][1]=0.0809586;
SineNegOddTracker[3][1]=0.0294876;
SineNegOddTracker[4][1]=0.0267047;
 
CosineNegOddTracker[0][2]=-0.058595;
CosineNegOddTracker[1][2]=-0.0317975;
CosineNegOddTracker[2][2]=-0.0168191;
CosineNegOddTracker[3][2]=0.00695534;
CosineNegOddTracker[4][2]=0.00600088;
 
SineNegOddTracker[0][2]=-0.0390209;
SineNegOddTracker[1][2]=-0.0262543;
SineNegOddTracker[2][2]=0.00389968;
SineNegOddTracker[3][2]=-0.00799938;
SineNegOddTracker[4][2]=-0.0106961;
 
CosineNegOddTracker[0][3]=0.0260213;
CosineNegOddTracker[1][3]=0.00379824;
CosineNegOddTracker[2][3]=-0.00625075;
CosineNegOddTracker[3][3]=-0.000552712;
CosineNegOddTracker[4][3]=0.0114154;
 
SineNegOddTracker[0][3]=-0.0100406;
SineNegOddTracker[1][3]=-0.0204619;
SineNegOddTracker[2][3]=0.00643397;
SineNegOddTracker[3][3]=-0.00454366;
SineNegOddTracker[4][3]=-0.0143757;
 
CosineNegOddTracker[0][4]=0.00793056;
CosineNegOddTracker[1][4]=0.00641362;
CosineNegOddTracker[2][4]=-0.00334052;
CosineNegOddTracker[3][4]=0.0101754;
CosineNegOddTracker[4][4]=0.023811;
 
SineNegOddTracker[0][4]=0.0268432;
SineNegOddTracker[1][4]=0.00896421;
SineNegOddTracker[2][4]=-0.00491065;
SineNegOddTracker[3][4]=-0.00517036;
SineNegOddTracker[4][4]=0.0183688;
 
CosineNegOddTracker[0][5]=-0.00670965;
CosineNegOddTracker[1][5]=-0.0230799;
CosineNegOddTracker[2][5]=-0.00284914;
CosineNegOddTracker[3][5]=0.00250473;
CosineNegOddTracker[4][5]=-0.00481755;
 
SineNegOddTracker[0][5]=0.0154761;
SineNegOddTracker[1][5]=0.000335504;
SineNegOddTracker[2][5]=-0.00732461;
SineNegOddTracker[3][5]=0.0120671;
SineNegOddTracker[4][5]=0.0211395;
 
CosineNegOddTracker[0][6]=-0.00495505;
CosineNegOddTracker[1][6]=-0.00306554;
CosineNegOddTracker[2][6]=-0.00687547;
CosineNegOddTracker[3][6]=0.000825254;
CosineNegOddTracker[4][6]=-0.0129254;
 
SineNegOddTracker[0][6]=0.0110206;
SineNegOddTracker[1][6]=-0.0245036;
SineNegOddTracker[2][6]=-0.0155756;
SineNegOddTracker[3][6]=-0.0115944;
SineNegOddTracker[4][6]=0.00769879;
 
CosineNegOddTracker[0][7]=-0.000361322;
CosineNegOddTracker[1][7]=-0.00389915;
CosineNegOddTracker[2][7]=-0.000281197;
CosineNegOddTracker[3][7]=-0.00422933;
CosineNegOddTracker[4][7]=0.00935204;
 
SineNegOddTracker[0][7]=-0.0114621;
SineNegOddTracker[1][7]=-0.0129282;
SineNegOddTracker[2][7]=0.00284699;
SineNegOddTracker[3][7]=-0.0176179;
SineNegOddTracker[4][7]=-0.0132533;
 
CosineNegOddTracker[0][8]=0.0110507;
CosineNegOddTracker[1][8]=-0.00601393;
CosineNegOddTracker[2][8]=0.00299397;
CosineNegOddTracker[3][8]=0.00916775;
CosineNegOddTracker[4][8]=-0.00170915;
 
SineNegOddTracker[0][8]=-0.00462559;
SineNegOddTracker[1][8]=-0.0112776;
SineNegOddTracker[2][8]=-0.00719766;
SineNegOddTracker[3][8]=0.00589439;
SineNegOddTracker[4][8]=-0.00392315;
 
CosineNegOddTracker[0][9]=0.00715906;
CosineNegOddTracker[1][9]=0.00336084;
CosineNegOddTracker[2][9]=0.00653852;
CosineNegOddTracker[3][9]=-0.0182451;
CosineNegOddTracker[4][9]=0.00321025;
 
SineNegOddTracker[0][9]=0.00564218;
SineNegOddTracker[1][9]=-0.00302691;
SineNegOddTracker[2][9]=0.00189628;
SineNegOddTracker[3][9]=0.0184726;
SineNegOddTracker[4][9]=0.0180733;
 
 
//Mid Tracker
CosineMidOddTracker[0][0]=-0.00823766;
CosineMidOddTracker[1][0]=0.0024081;
CosineMidOddTracker[2][0]=0.0207313;
CosineMidOddTracker[3][0]=0.0132396;
CosineMidOddTracker[4][0]=0.00652067;
 
SineMidOddTracker[0][0]=-0.0782646;
SineMidOddTracker[1][0]=-0.0784445;
SineMidOddTracker[2][0]=-0.0713943;
SineMidOddTracker[3][0]=-0.0537928;
SineMidOddTracker[4][0]=-0.0312576;
 
CosineMidOddTracker[0][1]=-0.00570496;
CosineMidOddTracker[1][1]=-0.00210206;
CosineMidOddTracker[2][1]=-0.0107653;
CosineMidOddTracker[3][1]=-0.00507436;
CosineMidOddTracker[4][1]=0.00196604;
 
SineMidOddTracker[0][1]=-0.0169424;
SineMidOddTracker[1][1]=-0.00984171;
SineMidOddTracker[2][1]=-0.00409085;
SineMidOddTracker[3][1]=-0.0221839;
SineMidOddTracker[4][1]=-0.00741277;
 
CosineMidOddTracker[0][2]=-0.00723337;
CosineMidOddTracker[1][2]=0.00420426;
CosineMidOddTracker[2][2]=-0.0130246;
CosineMidOddTracker[3][2]=-0.00102114;
CosineMidOddTracker[4][2]=-0.00118979;
 
SineMidOddTracker[0][2]=0.0123394;
SineMidOddTracker[1][2]=-0.00478678;
SineMidOddTracker[2][2]=0.00792307;
SineMidOddTracker[3][2]=0.0021016;
SineMidOddTracker[4][2]=-0.00673872;
 
CosineMidOddTracker[0][3]=-0.00558022;
CosineMidOddTracker[1][3]=0.00326597;
CosineMidOddTracker[2][3]=-0.00601669;
CosineMidOddTracker[3][3]=-0.00164544;
CosineMidOddTracker[4][3]=0.00148368;
 
SineMidOddTracker[0][3]=-0.00157227;
SineMidOddTracker[1][3]=3.77377e-05;
SineMidOddTracker[2][3]=0.0029838;
SineMidOddTracker[3][3]=0.00460932;
SineMidOddTracker[4][3]=-0.015612;
 
CosineMidOddTracker[0][4]=0.00187636;
CosineMidOddTracker[1][4]=0.00570734;
CosineMidOddTracker[2][4]=0.00753964;
CosineMidOddTracker[3][4]=0.00433591;
CosineMidOddTracker[4][4]=0.0123835;
 
SineMidOddTracker[0][4]=0.00444359;
SineMidOddTracker[1][4]=-0.0204701;
SineMidOddTracker[2][4]=-0.0172248;
SineMidOddTracker[3][4]=-0.0146342;
SineMidOddTracker[4][4]=0.00411355;
 
CosineMidOddTracker[0][5]=0.00153873;
CosineMidOddTracker[1][5]=-0.018992;
CosineMidOddTracker[2][5]=-0.0211428;
CosineMidOddTracker[3][5]=0.00253074;
CosineMidOddTracker[4][5]=0.0152987;
 
SineMidOddTracker[0][5]=-0.00421467;
SineMidOddTracker[1][5]=-0.0202538;
SineMidOddTracker[2][5]=0.00501977;
SineMidOddTracker[3][5]=0.00437823;
SineMidOddTracker[4][5]=-0.00341817;
 
CosineMidOddTracker[0][6]=-0.0143096;
CosineMidOddTracker[1][6]=-0.011767;
CosineMidOddTracker[2][6]=0.00541577;
CosineMidOddTracker[3][6]=0.00296813;
CosineMidOddTracker[4][6]=0.00028093;
 
SineMidOddTracker[0][6]=0.00634756;
SineMidOddTracker[1][6]=0.00469609;
SineMidOddTracker[2][6]=-0.0104487;
SineMidOddTracker[3][6]=-0.0261953;
SineMidOddTracker[4][6]=-0.0160071;
 
CosineMidOddTracker[0][7]=-0.00120991;
CosineMidOddTracker[1][7]=-0.00202007;
CosineMidOddTracker[2][7]=-0.00898644;
CosineMidOddTracker[3][7]=-0.0157684;
CosineMidOddTracker[4][7]=-0.0135475;
 
SineMidOddTracker[0][7]=-0.00438585;
SineMidOddTracker[1][7]=-0.0105633;
SineMidOddTracker[2][7]=-0.00404263;
SineMidOddTracker[3][7]=-0.00836517;
SineMidOddTracker[4][7]=-0.00448998;
 
CosineMidOddTracker[0][8]=-0.00590549;
CosineMidOddTracker[1][8]=-0.00645646;
CosineMidOddTracker[2][8]=0.000220727;
CosineMidOddTracker[3][8]=-0.0105563;
CosineMidOddTracker[4][8]=-0.0106966;
 
SineMidOddTracker[0][8]=-0.00523074;
SineMidOddTracker[1][8]=0.0170268;
SineMidOddTracker[2][8]=0.0138244;
SineMidOddTracker[3][8]=-0.00315566;
SineMidOddTracker[4][8]=-0.0116928;
 
CosineMidOddTracker[0][9]=0.0179283;
CosineMidOddTracker[1][9]=0.0231952;
CosineMidOddTracker[2][9]=-0.00346072;
CosineMidOddTracker[3][9]=0.0114228;
CosineMidOddTracker[4][9]=-0.0022534;
 
SineMidOddTracker[0][9]=-0.00873695;
SineMidOddTracker[1][9]=0.0114523;
SineMidOddTracker[2][9]=-0.0055753;
SineMidOddTracker[3][9]=-0.0162885;
SineMidOddTracker[4][9]=-0.011477;
 


}//End of Fill Angular Corrections Function

+EOF
