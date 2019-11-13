



/**
 * @file NBA_MVP_Ballot.sol
 * @author Mohammed Samsuddin <mshmsudd@buffalo.edu>
 * @author Taktuk Taktuk      <taktukta@buffalo.edu>
 * @date created 22nd Sept 2019
 * @date last modified 29th Sept 2019
 */

pragma solidity >=0.4.22 <0.6.0;

contract NBA_MVP_Ballot {
    

// -------------------------------------------------------------- Data and Attributes ----------------------------------------------------------------------------------------
    
    
    // A voter has 3 attributes, his address
    // boolean variable hasVoted
    // And boolean variable isRegistered
    struct voter{
        address voterAddress;
        bool hasVoted;
        bool isRegistered;

    }
    

    // a player have 3 attributes
    // an integer variable player ID 
    // an integer variable points
    // an boolean variable isRegistered
    struct Player{
        uint playerId;
        uint points;            // can we update this along the way?
        bool isRegistered;
                
    }
    
    Player[5] player;   // only 5 players are allowed to participate in the election
    uint public candidateNumber = 0 ;   // to keep track of how many candidates there are
    uint public voterNumber = 0 ;   // to keep track of how many voter there are
    uint public totalVote = 0; // total number of vote
    uint public winner = 0;
    
    // The ballot official name, wallet address and proposal are kept as public variables for everyone to see. 
    address public ballotOfficialAddress; 
    
    uint iter= 0;      //         

    // candidate are stored in a mapping called candidateRegister
    mapping(uint => Player) candidateRegister;  
    
    // voter are stored in a mapping called voterRegister.
    // voterRegister is public so anyone can check who are the eligible voters.
    // One may ask why I wouldn't store my voters in arrays.
    // The challenge with using arrays in an Ethereum blockchain is that you are likely to start running out of gas while trying to traverse the records of a considerably sized array.
    mapping(address => voter) voterRegister;
    
    mapping(address => uint) votePreference;  // for preference.
    
    mapping(uint => uint) candidatePoints;  // i = 0... 4     =>   playerID1 , playerID2, playerID3 ,... playerID5
    
    
    // The ballot contract goes through 3 states.
    // When the chairman creates it, it is in the state of "Created".
    // Once he indicates that voting starts, the ballot contract turns to the state of "Voting".
    // When counting starts, the goes into the state of "Ended". 
    enum State { Created, Voting, Ended }
	State public state;


// -------------------------------------------------------------- Modifiers ----------------------------------------------------------------------------------------

    // The onlyOfficial() modifier
    // calling this function is the same address as what is saved in ballotOfficialAddress.
    // This ensures that only the oficial himself is allowed to call the function.
    // In the event that the official denies ever starting the ballot, this will serve as evidence that it was really him, unless someone stole his wallet and private key.
	modifier onlyOfficial() {
		require(msg.sender == ballotOfficialAddress);
		_;
	}

    // The modifier for inState is declared from lines 89 to 94.
    // It checks to ensure that the contract is currently in the state provided as variable to the inState() modifier.
	modifier inState(State _state) {
		require(state == _state);
		_;
	}


// -------------------------------------------------------------- Events ----------------------------------------------------------------------------------------

    // event
    event voterAdded(uint voterNum);
    event voterRemoved(uint voterNum);
    event candidateAdded(uint _candidateID, uint _numOfCandidate);
    event voteStarted();
    event voteEnded(uint finalResult);
    event voteDone(address voter, uint totalVote);



// -------------------------------------------------------------- Functions ----------------------------------------------------------------------------------------



    // Creates a new ballot contract.
	// The official initializes the contract with the constructor by providing his _ballotOfficialName and _proposal.
	// The constructor reads his wallet address and update the ballotOfficialAddress.
	// This is important because folks who might wonder if this is a legitimate ballot can compare what they know is the chairman's wallet address to what is saved here.
	// At this point, the state of the contract is "Created"
	constructor() public {
	    
        ballotOfficialAddress = msg.sender;
        state = State.Created;
    }


    // to register such voter, we will locate their voter object and make their instance variable isRegistered to true
    function registerVoter(address _voterAddress) public inState(State.Created) onlyOfficial returns (uint) {
        
        require(_voterAddress != ballotOfficialAddress);
        
        // the ballot official are not allowed to vote
        if(!(voterRegister[_voterAddress].isRegistered)) {
            voter memory v;
            v.voterAddress = _voterAddress;
            v.hasVoted = false;
            v.isRegistered = true;
            voterRegister[_voterAddress] = v;  //voter ( voterId , hasVoted , isRegistered)
            voterNumber++;
        }

        emit voterAdded(voterNumber);
        return voterNumber;
    }
    
    
    
    // candidate means the Player that will be contending for MVP 
    // this function will take in the playerID of candidate and register them accordingdly
    function registerCandidate(uint _playerId) public inState(State.Created) onlyOfficial returns (uint) {
        
        if (candidateNumber > 5) {
             return candidateNumber;
        } else if (candidateNumber < 5 && !(candidateRegister[_playerId].isRegistered)) {
            candidateRegister[_playerId] = Player(_playerId, 0, true) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
            candidateNumber++;  // now that we have a candidate registered , we can increase the counter
            candidatePoints[iter] = _playerId;  // pair each number 0...4 with playerID 
            iter++;
        }
        emit candidateAdded(_playerId, candidateNumber);
        return candidateNumber;
    }


    // to unregister such candidate, we will locate their Player object and make their instance variable isRegistered to false
    function unRegisterCandidate(uint _playerId) public inState(State.Created) onlyOfficial returns (uint) {
        //candidateRegister[_playerId] = Player(_playerId, 0, false) ;  //registerCandidate("LBJ")  ...  source: https://solidity.readthedocs.io/en/v0.4.24/types.html
        
        if(candidateRegister[_playerId].isRegistered) {
            delete candidateRegister[_playerId];
            candidateNumber--;
        }
            
            
        /*for (uint i = 0; i <= candidateNumber; i++){
            if(candidateRegister[i].playerId == _playerId){
                player[i] = Player(0,0,false);  // if player exists in player array.. remove it somehow
                candidateNumber--;
            }
        }*/
           
        return candidateNumber; 
    }

    // to unregister such voter, we will locate their voter object and make their instance variable isRegistered to false
    function unRegisterVoter(address _voterAddress) public inState(State.Created) onlyOfficial returns (uint) {

        if(voterRegister[_voterAddress].isRegistered) {
            delete voterRegister[_voterAddress];   // hasVoted == false
            voterNumber--;
        }

        emit voterRemoved(voterNumber);
        return voterNumber;
    }

                                
                                
                                
    // declare voting starts now
    function startVoting() public inState(State.Created) onlyOfficial returns (uint) {    
        emit voteStarted();
        state = State.Voting; 
        return 1;
    }
    

    // user will enter playerId of their top preferences
    // the candidates will have their points updated accoridng to the voter's preferences
    function votePlayer(address _voterAddress , uint pref1 , uint pref2, uint pref3, uint pref4, uint pref5) public inState(State.Voting) returns(uint){
        
        require(_voterAddress != ballotOfficialAddress);

        if(voterRegister[_voterAddress].isRegistered && !(voterRegister[_voterAddress].hasVoted)) {  // verifying that voter is registered
            if(candidateRegister[pref1].isRegistered) {       
                candidateRegister[pref1].points += 10;  
            } 
            
            if(candidateRegister[pref2].isRegistered) {
                candidateRegister[pref2].points += 7;
            }
            
            if(candidateRegister[pref3].isRegistered) {
                candidateRegister[pref3].points += 5;
            }
            
            if(candidateRegister[pref4].isRegistered) {
                candidateRegister[pref4].points += 3;
            }
            
            if(candidateRegister[pref5].isRegistered) {
                candidateRegister[pref5].points += 1;
            }
            voterRegister[_voterAddress].hasVoted = true;
            totalVote++;
                                                               //vote!  update players points accordingly
        }
    
        emit voteDone(msg.sender, totalVote);
        return totalVote;
    }
    
    
    
    // End the voting
    function endVoting() public inState(State.Voting) onlyOfficial returns (uint) {
        state = State.Ended;
        return 2;
    }
    
    
    // this is used to collect all the points. We do so by accessing the playerID of the hashmap to get value -> points
    function tallyPoints (uint _playerId) public view inState(State.Ended) returns (uint){
        uint _points;
        if(candidateRegister[_playerId].isRegistered) {
            _points = candidateRegister[_playerId].points;
        }
        return _points;
    }
    
    
    // Return the Winner
    function winningProposal() public inState(State.Ended) returns (uint){
        
        uint256 mostPoints = 0;
         
        
        for (uint i = 0; i < candidateNumber; i++){
            if (candidateRegister[candidatePoints[i]].points > mostPoints) {    // candidate[i] gives u the ID of candidate
                mostPoints = candidateRegister[candidatePoints[i]].points;     // each int .. from 0 to 4 is paired with                                                                  
                winner = candidatePoints[i];
            }
        }
        
        emit voteEnded(winner);
        return winner;
    }
    
    
    
    
    
}   // END OF NBA_MVP_Ballot
