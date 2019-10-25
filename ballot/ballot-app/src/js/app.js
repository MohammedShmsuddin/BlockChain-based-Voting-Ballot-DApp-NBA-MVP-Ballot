App = {
  web3Provider: null,
  contracts: {},
  url: 'http://127.0.0.1:7545',
  chairPerson:null,
  currentAccount:null,
  



   init: function() {
     return App.initWeb3();
   },
  
  
   initWeb3: function() {
        // Is there is an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
    } else {
      // If no injected web3 instance is detected, fallback to the TestRPC
      App.web3Provider = new Web3.providers.HttpProvider(App.url);
    }
    web3 = new Web3(App.web3Provider);

    ethereum.enable();

    App.populateAddress();
    return App.initContract();
  },

  initContract: function() {
      $.getJSON('NBA_MVP_Ballot.json', function(data) {
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var voteArtifact = data;
    App.contracts.vote = TruffleContract(voteArtifact);

    // Set the provider for our contract
    App.contracts.vote.setProvider(App.web3Provider);

    App.getChairperson();
    return App.bindEvents();
  });
  },


  bindEvents: function() {    // none of these functions are working at the moments
    $(document).on('click', '.btn-vote', App.markVoted(chairperson,currentAccount));
    $(document).on('click', '.btn-winner', App.handleWinner);
    $(document).on('click', '.btn-register', function(){ var ad = $('#enter_address').val(); App.handleRegister(ad); });
  },



   populateAddress : function(){ },   //second most
  
   getChairperson : function(){ },        //most important
  
   handleRegister: function(addr){ },
  
   handleVote: function(event){ },
  
   handleWinner : function(){ } ,

    markVoted: function(voters , account){            //https://www.trufflesuite.com/tutorials/pet-shop

var voteInstance;

App.contracts.vote.deployed().then(function(instance) {  // instance : json 

  voteInstance = instance;

  return voteInstance.getChairperson.call();  // call to getChairPerson , if vote pressed, disable it
}).then(function(voters) {
  for (i = 0; i < voters.length; i++) {
    if (voters[i] !== '0x0000000000000000000000000000000000000000') {
      $('btn-vote').find('button').text('Success').attr('disabled', true);
    }
  }
}).catch(function(err) {
  console.log(err.message);
});


};  // end bindEvents



  


};      //endApp

  


$(function() {
  $(window).load(function() {
    App.init();
  });
});