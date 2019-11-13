 App = {

  web3Provider: null,
  contracts: {},
  url: 'http://127.0.0.1:7545',
  chairPerson:null,
  currentAccount:null,
  numOfcandidate: 0,



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
  bindEvents: function() {    

    $(document).on('click', '#btnStart', App.startVote);
    $(document).on('click', '#btnEnd', App.endVote);
    $(document).on('click', '#win-count', App.winner);

    $(document).on('click', '#tally-button', function(){
      var points = $('#tally-points').val(); 
      App.checkPoints(points);
    }); 

    $(document).on('click', '#btnAdd1', function(){ var ad = $('#enter_address').val(); App.addVoter(ad); });
    $(document).on('click', '#btnAdd2', function(){ var name = $('#candidateName').val(); var id = $('#candidateID').val();   App.addCandidate(name, id); });

    $(document).on('click', '#vote',  function(){ 
      var ad = $('#voterAddress').val(); 
      var first = $('#firstPick').val();
      var second = $('#secondPick').val();
      var third = $('#thirdPick').val();
      var fourth= $('#fourthPick').val();
      var fifth= $('#fifthPick').val();

      App.handleVote(ad,first,second,third,fourth,fifth);

    });

    $(document).on('click', '#btnRemoveVoter', function(){
      var voterAddress = $('#address-remove').val();
      App.removeVoter(voterAddress);
    });


    $(document).on('click', '#btnRemoveCandidate', function(){
      var candidateID = $('#candidateIDtoRemove').val();
      App.removeCandidate(candidateID);
    });

  },



  // takes in playerID -> returns points
  // returns uint --> points                    
  checkPoints : function(candidateID){
    var voteInstance;
    App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.tallyPoints(candidateID);   // how can display this result??
    }).then(function(result, err){
      if(result){
          alert(candidateID + " recieved " + result + " points")
      } else {
          alert(result + "  failed")
      }   
    });

  },



  /**
   * 
   */
  winner : function(){      //what does result output... how can get result from calling solidity function winningProposal..
    var voteInstance;
    App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.winningProposal();
    }).then(function(result, err){
      if(result){
          //console.log("our new results: " + JSON.stringify(result));
          alert("Candidate " + result["logs"]["0"]["args"]["finalResult"] + " has Won!")           
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
        $(document).ready(function(){
          $("#lbl_state").text("State: Created");
          $("#lbl_address").text("Official Address: " + App.chairPerson);
          $("#lbl_voters_num").text("Number Of Voters: " + 0);
          $("#lbl_votes_num").text("Number Of Votes: " + 0);

        });
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
        if(parseInt(result.receipt.status) == 1) {
            alert(addr + " registration done successfully")
            //console.log("add voter: " + JSON.stringify(result));
            $(document).ready(function(){
              $("#lbl_voters_num").text("Number Of Voters: " + result["logs"]["0"]["args"]["voterNum"]);
              $('#voterTable').append('<tr><td>'+result["logs"]["0"]["args"]["voterNum"]+'</td><td>'+addr+'</td></tr>');
            });

        } else {
            alert(addr + " registration not done successfully due to revert")
        }
      } else {
            alert(addr + " registration failed")
      }   

    });

  },   


  
  /**
   * takes in voter address to remove
   * @param {*} addr 
   */
  removeVoter : function(addr){

    var voteInstance;
    App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.unRegisterVoter(addr);
    }).then(function(result, err){
        if(result){
            if(parseInt(result.receipt.status) == 1) {
              alert(addr + " has been remove successfully")
              //console.log("remove voter: " + JSON.stringify(result));
              $(document).ready(function(){
                $("#lbl_voters_num").text("Number Of Voters: " + result["logs"]["0"]["args"]["voterNum"]);
                $("#voterTable tr td:contains('" + addr + "')").filter(function() {
                  return $(this).text().trim() == addr;
                }).parent().remove();

              });
            } else {
              alert(addr + " registration not done successfully due to revert")
            }
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
  addCandidate : function(name, addr){  // need to id each candidate 0...4
        
    var voteInstance;
    App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.registerCandidate(addr);
    }).then(function(result, err){
      if(result){
          if(parseInt(result.receipt.status) == 1 && App.numOfcandidate < 5) {
              App.numOfcandidate++;
              alert("Candidate " + addr + " registration done successfully")
              $(document).ready(function(){
                $('#candidateTable').append('<tr><td>'+addr+'</td><td>'+name+'</td></tr>');
              });

          } else {
              alert(addr + " registration not done successfully due to revert")
          }  
      } else {
          alert(addr + " registration failed")
      }

    });


  },   



  /**
   * 
   * @param {*} addr 
   */
  removeCandidate: function(addr){

    var voteInstance;
    App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.unRegisterCandidate(addr);
    }).then(function(result, err){
      if(result){
          if(parseInt(result.receipt.status) == 1) {
              App.numOfcandidate--;
              alert("Candidate " + addr + " has been remove successfully")
              $("#candidateTable tr td:contains('" + addr + "')").filter(function() {
                return $(this).text().trim() == addr;
              }).parent().remove();
              
          } else {
              alert(addr + " registration not done successfully due to revert")
          }  
      } else {
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
  }).then(function(result, err) {
    if(result) {
      //console.log("vote: " + JSON.stringify(result));
      $(document).ready(function(){
        $("#lbl_votes_num").text("Number Of Votes: " + result["logs"]["0"]["args"]["totalVote"]);
      });

    }
  });

},
  
   

populateAddress : function(){
  new Web3(new Web3.providers.HttpProvider(App.url)).eth.getAccounts((err, accounts) => {
    jQuery.each(accounts,function(i){
      if(web3.eth.coinbase != accounts[i]){
          var optionElement = '<option value="'+accounts[i]+'">'+accounts[i]+'</option';
          jQuery('#enter_address').append(optionElement);  
          jQuery('#address-remove').append(optionElement);
      }
    });
  });
},



   
startVote : function(event) {

  var voteInstance;
  App.contracts.vote.deployed().then(function(instance) {
      voteInstance = instance;
      return voteInstance.startVoting();
  }).then(function(result, err) {
    if(result) {
      $(document).ready(function(){
        $("#lbl_state").text("State: Voting");
      });

    }
      
  });
   
},


endVote : function(event) {

  var voteInstance;
  App.contracts.vote.deployed().then(function(instance) {
    voteInstance = instance;
    return voteInstance.endVoting();
  }).then(function(result, err) {
    if(result) {
      $(document).ready(function(){
        $("#lbl_state").text("State: Ended");
      });

    }

  });

},





};      // End of DApp





$(function() {
  $(window).load(function() {
    App.init();
  });
});