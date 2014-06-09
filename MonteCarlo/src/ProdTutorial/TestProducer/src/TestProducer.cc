// system include files
#include <memory>

// user include files
#include "FWCore/Framework/interface/Frameworkfwd.h"
#include "FWCore/Framework/interface/EDProducer.h"

#include "FWCore/Framework/interface/Event.h"
#include "FWCore/Framework/interface/MakerMacros.h"

#include "FWCore/ParameterSet/interface/ParameterSet.h"

#include "DataFormats/TrackReco/interface/Track.h"
#include "DataFormats/TrackReco/interface/TrackFwd.h"
#include <vector>
#include "Math/Vector3D.h"

#include "FWCore/Framework/interface/MakerMacros.h"
#include "FWCore/ServiceRegistry/interface/Service.h"
#include "CommonTools/UtilAlgos/interface/TFileService.h"
//#include "DataFormats/HeavyIonEvent/interface/CentralityProvider.h"
#include <DataFormats/VertexReco/interface/Vertex.h>
#include <DataFormats/VertexReco/interface/VertexFwd.h>
#include <DataFormats/TrackReco/interface/Track.h>
#include <DataFormats/TrackReco/interface/TrackFwd.h>
#include "SimDataFormats/TrackingAnalysis/interface/TrackingParticle.h"
#include "SimDataFormats/TrackingAnalysis/interface/TrackingParticleFwd.h"
#include "SimTracker/Records/interface/TrackAssociatorRecord.h"
#include "DataFormats/RecoCandidate/interface/TrackAssociation.h"
#include "SimTracker/TrackAssociation/interface/TrackAssociatorByHits.h"



//
// class declaration
//

class TestProducer : public edm::EDProducer {
   public:
      explicit TestProducer(const edm::ParameterSet&);
      ~TestProducer();

     private:
      virtual void beginJob() ;
      virtual void produce(edm::Event&, const edm::EventSetup&);
      virtual void endJob() ;
      
  // ----------member data ---------------------------
  //typedef std::vector<float> JaimesTrackCollection;
  
  edm::InputTag vertexSrc_;
  edm::InputTag trackSrc_;
  edm::InputTag tpFakSrc_;
  edm::InputTag tpEffSrc_;
  edm::InputTag associatorMap_;

};

//
// constants, enums and typedefs
//


//
// static data member definitions
//

//
// constructors and destructor
//
TestProducer::TestProducer(const edm::ParameterSet& iConfig):
  vertexSrc_(iConfig.getParameter<edm::InputTag>("vertexSrc")),
  trackSrc_(iConfig.getParameter<edm::InputTag>("trackSrc")),
  tpFakSrc_(iConfig.getParameter<edm::InputTag>("tpFakSrc")),
  tpEffSrc_(iConfig.getParameter<edm::InputTag>("tpEffSrc")),
  associatorMap_(iConfig.getParameter<edm::InputTag>("associatorMap"))
{
  
  //Make My Reco Track Collection
  produces<reco::TrackCollection>();
  
  
  
}


TestProducer::~TestProducer()
{
 
   // do anything here that needs to be done at desctruction time
   // (e.g. close files, deallocate resources etc.)

}


//
// member functions
//

// ------------ method called to produce the data  ------------
void
TestProducer::produce(edm::Event& iEvent, const edm::EventSetup& iSetup)
{
   using namespace edm;
   using namespace std;
   using namespace reco;
 
   // obtain collections of simulated particles 
   edm::Handle<TrackingParticleCollection>  TPCollectionHeff, TPCollectionHfake;
   iEvent.getByLabel(tpEffSrc_,TPCollectionHeff);
   iEvent.getByLabel(tpFakSrc_,TPCollectionHfake);

   // obtain association map between tracks and simulated particles
   reco::RecoToSimCollection recSimColl;
   reco::SimToRecoCollection simRecColl;
   edm::Handle<reco::SimToRecoCollection > simtorecoCollectionH;
   edm::Handle<reco::RecoToSimCollection > recotosimCollectionH;
   iEvent.getByLabel(associatorMap_,simtorecoCollectionH);
   simRecColl= *(simtorecoCollectionH.product());
   iEvent.getByLabel(associatorMap_,recotosimCollectionH);
   recSimColl= *(recotosimCollectionH.product());

   // obtain reconstructed tracks
   Handle<edm::View<reco::Track> > tcol;
   iEvent.getByLabel(trackSrc_, tcol);

   // obtain primary vertices
   Handle<std::vector<reco::Vertex> > vertex;
   iEvent.getByLabel(vertexSrc_, vertex);

   //Output
   /*std::auto_ptr<JaimesTrackCollection> pt(new JaimesTrackCollection);
   std::auto_ptr<JaimesTrackCollection> eta(new JaimesTrackCollection);
   std::auto_ptr<JaimesTrackCollection> phi(new JaimesTrackCollection);
   */
   std::auto_ptr<reco::TrackCollection> tracksOut(new reco::TrackCollection);
   

   

   for(edm::View<reco::Track>::size_type i=0; i<tcol->size(); ++i)
     {
       
       edm::RefToBase<reco::Track> track(tcol, i);
       reco::Track* tr=const_cast<reco::Track*>(track.get());
       
       
       // look for match to simulated particle, use first match if it exists                                 
       std::vector<std::pair<TrackingParticleRef, double> > tp;
       const TrackingParticle *mtp=0;
       if(recSimColl.find(track) != recSimColl.end())
	 {
	 }
       else
	 {
	   const reco::Track & theTrack = * tr;
	   tracksOut->push_back(reco::Track(theTrack));
	 }
     }//end of loop over tracks
   
   iEvent.put(tracksOut);

 
}

// ------------ method called once each job just before starting event loop  ------------
void 
TestProducer::beginJob()
{
}

// ------------ method called once each job just after ending the event loop  ------------
void 
TestProducer::endJob() {
}


//define this as a plug-in
DEFINE_FWK_MODULE(TestProducer);