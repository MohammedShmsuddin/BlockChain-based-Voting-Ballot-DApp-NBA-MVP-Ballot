 App = {

  web3Provider: null,
  contracts: {},
  player: new Array(),
  url: 'http://127.0.0.1:7545',


  chairPerson:null,
  currentAccount:null,
  



   init: function() {
     return App.initWeb3();
   },
  
  /**
   * 
   */
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



  /**
   * 
   */
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




  /**
   * 
   */
  bindEvents: function() {    // none of these functions are working at the moments
    $(document).on('click', '#btn-vote', App.markVoted(chairperson,currentAccount));
    $(document).on('click', '#btn-winner', App.winningProposal);
    $(document).on('click', '#btnAdd1', function(){ var ad = $('#enter_address').val(); App.addVoter(ad); });
    $(document).on('click', '#btnAdd2', function(){ var name = $('#candidateName').val(); var id = $('#candidateID').val(); App.addCandidate(name, id); });
    $(document).on('click', '#vote', function(){ var ad = $('#voterAddress').val(); App.handleVote(ad); });
    $(document).on('click', '#btnStart', App.startVote);
    $(document).on('click', '#btnEnd', App.endVote);
    

  },

  getChairperson : function(){
    App.contracts.vote.deployed().then(function(instance) {
      return instance;
    }).then(function(result) {
      App.chairPerson = result.constructor.currentProvider.selectedAddress.toString();
      App.currentAccount = web3.eth.coinbase;
      if(App.chairPerson != App.currentAccount){
        jQuery('#panels_new_Ballot').css('display','none');
        jQuery('#panels_voters').css('display','none');
        jQuery('#panels_candidate').css('display','none');
      }else{
        jQuery('#panels_new_Ballot').css('display','block');
        jQuery('#panels_voters').css('display','block');
        jQuery('#panels_candidate').css('display','block');
      }
    })
  },



  /**
   * 
   * @param {*} addr 
   */
   addVoter : function(addr){

        var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.register(addr);
        }).then(function(result, err){
            if(result){
                if(parseInt(result.receipt.status) == 1)
                alert(addr + " registration done successfully")
                else
                alert(addr + " registration not done successfully due to revert")
            } else {
                alert(addr + " registration failed")
            }   
        });

    },   
  

    /**
     * 
     * @param {*} name 
     * @param {*} id 
     */
   addCandidate : function(name, id){



    },   
   

   /**
    * 
    * @param {*} event 
    */
   startVote : function(event) {

    $('btnGo').find('button').attr('disabled', true);
    $('btnStart').find('button').attr('disabled', true);
    $('btnAdd1').find('button').attr('disabled', true);
    $('btnAdd2').find('button').attr('disabled', true);

   },


   endVote : function(event) {

    $('vote').find('button').attr('disabled', true);
    $('btnEnd').find('button').attr('disabled', true);

   },
  

   handleVote: function(ad, event){ },
  
   winningProposal : function(){ },

   tallyPoints : function() { },




   /**
    * 
    * @param {*} voters 
    * @param {*} account 
    */
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
   },




   /**
    * 
    */
   populateAddress : function(){
    new Web3(new Web3.providers.HttpProvider(App.url)).eth.getAccounts((err, accounts) => {
      jQuery.each(accounts,function(i){
        if(web3.eth.coinbase != accounts[i]){
          var optionElement = '<option value="'+accounts[i]+'">'+accounts[i]+'</option';
          jQuery('#enter_address').append(optionElement);  
        }
      });
    });
  },












};      // End of DApp

  


$(function() {
  $(window).load(function() {
    App.init();
  });
});