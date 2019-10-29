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
  
  //https://web3js.readthedocs.io/en/v2.0.0-alpha/web3-eth-contract.html#contract-call
  //web3 allows our client side to talk to blockchain/ropstein
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



  initContract: function() {
      $.getJSON('NBA_MVP_Ballot.json', function(data) {
    // Get the necessary contract artifact file and instantiate it with truffle-contract
    var voteArtifact = data;
    App.contracts.vote = TruffleContract(voteArtifact); //Uncaught ReferenceError: TruffleContract is not defined
    
    // Set the provider for our contract
    App.contracts.vote.setProvider(App.web3Provider);

       App.getChairperson(); //initializes chairPerson and currentAccount

        return App.bindEvents();
  });

  },


  

  /**
   * 
   */
  bindEvents: function() {    // none of these functions are working at the moments

    $(document).on('click', '#btnStart', App.startVote);
    $(document).on('click', '#btnEnd', App.endVote);
    $(document).on('click', '#win-count', App.winner);

    $(document).on('click', '#tally-button', function(){
      var points = $('#tally-points').val(); 
      App.checkPoints(points);
    }); 

    $(document).on('click', '#btnAdd1', function(){ var ad = $('#enter_address').val(); App.addVoter(ad); });
    $(document).on('click', '#btnAdd2', function(){ 
      var name = $('#candidateName').val(); var id = $('#candidateID').val();  
       App.addCandidate(id); 
    });

    $(document).on('click', '#vote',  function(){ 
      var ad = $('#voterAddress').val(); 
      var first = $('#firstPick').val();
      var second = $('#secondPick').val();
      var third = $('#thirdPick').val();
      var fourth= $('#fourthPick').val();
      var fifth= $('#fifthPick').val();

      App.handleVote(ad,first,second,third,fourth,fifth);

  });

  },

// takes in playerID -> returns points
//returns uint --> points                    not working 
checkPoints : function(candidateID){
var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.tallyPoints(candidateID);   // how can display this result??
 }).then(function(result, err){
            if(result){
                if(parseInt(result.receipt.status) == 1)
                alert(candidateID + " has  points")
                else
                alert(result + " not done successfully due to revert")
            } else {
                alert(result + "  failed")
            }   
        });
},

   // * @param {*} addr 

winner : function(){      //what does result output... how can get result from calling solidity function winningProposal..
var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.winningProposal();
 }).then(function(result, err){
            if(result){
                if(parseInt(result.receipt.status) == 1)
                alert(result + " has won!")
                else
                alert(result + " not done successfully due to revert")
            } else {
                alert(result + "  failed")
            }   
        });
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

  

   addVoter : function(addr){

        var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.registerVoter(addr);
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
     * our registerCandidate function maps uint 0...4 with the candidates ID we add.
     * @param {*} id 
     */
  addCandidate : function(addr){  // need to id each candidate 0...4
 var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.registerCandidate(addr);
        }).then(function(result, err){
            if(result){
                if(parseInt(result.receipt.status) == 1)    {
              alert(addr + " candidate registration done successfully")
               $('#candidate-list').append("<li>"+ addr +"</li>" );
          }
              else{
                alert(addr + " registration not done successfully due to revert")
         
          }  
        }


           else {
                alert(addr + " registration failed")
            }
          });



    },   

    /*

    function votePlayer(address _voterAddress , uint pref1 , uint pref2, uint pref3, uint pref4, uint pref5) public inState(State.Voting) {

*/
   
handleVote: function(addr,firstPick,secondPick,thirdPick,fourthPick,fifthPick){   // can subsitute addr with person deploying current contract..
var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.votePlayer(addr,firstPick,secondPick,thirdPick,fourthPick,fifthPick);
   });
   },
  
   

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

   /**
    * 
    * @param {*} event 
    */
   startVote : function(event) {

    $('btnGo').find('button').attr('disabled', true);  //Validate button
    $('btnStart').find('button').attr('disabled', true);  //StartVoting button
    $('btnAdd1').find('button').attr('disabled', true);  //Add Voter button
    $('btnAdd2').find('button').attr('disabled', true);   // Add Candidate button


var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.startVoting();
        });
   },


   endVote : function(event) {

    $('vote').find('button').attr('disabled', true);
    $('btnEnd').find('button').attr('disabled', true);

    var voteInstance;
        App.contracts.vote.deployed().then(function(instance) {
          voteInstance = instance;
          return voteInstance.endVoting();
        });

   },



};      // End of DApp

  


$(function() {
  $(window).load(function() {
    App.init();
  });
});