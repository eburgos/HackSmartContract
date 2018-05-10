/* This program is free software. It comes without any warranty, to
the extent permitted by applicable law. You can redistribute it
and/or modify it under the terms of the Do What The Fuck You Want
To Public License, Version 2, as published by Sam Hocevar. See
http://www.wtfpl.net/ for more details. */

/* These contracts are examples of contracts with vulnerabilities in order to practice your hacking skills.
DO NOT USE THEM OR GET INSPIRATION FROM THEM TO MAKE CODE USED IN PRODUCTION 
You are required to find vulnerabilities where an attacker harms someone else.
Being able to destroy your own stuff is not a vulnerability and should be dealt at the interface level.
*/

pragma solidity ^0.4.10;
//*** Exercise 1 ***//
// Simple token you can buy and send.
contract SimpleToken {
    mapping(address => uint) public balances;
    
    /// @dev Buy token at the price of 1ETH/token.
    function buyToken() payable {
        balances[msg.sender]+=msg.value / 1 ether;
    }
    
    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, uint _amount) {
        //This require was incorrectly checking for a balance <> 0 when it needed to check for amount
        //Solution: >= _amount instead of != 0
        require(balances[msg.sender] >= _amount); // You must have some tokens.
        
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }
    
}

//*** Exercise 2 ***//
// You can buy voting rights by sending ether to the contract.
// You can vote for the value of your choice.
contract VoteTwoChoices {
    mapping(address => uint) public votingRights;
    mapping(address => uint) public votesCast;
    mapping(bytes32 => uint) public votesReceived;
    
    /// @dev Get 1 voting right per ETH sent.
    function buyVotingRights() payable {
        votingRights[msg.sender]+=msg.value/(1 ether);
    }
    
    /** @dev Vote with nbVotes for a proposition.
     *  @param _nbVotes The number of votes to cast.
     *  @param _proposition The proposition to vote for.
     */
    function vote(uint _nbVotes, bytes32 _proposition) {
        //This require accepted 0 as _nbVotes making the contract able to accept casting a vote for 0 with multiple _propositions.
        //While it's true that the caller is spending gas it's probably a grief because it can
        //have the list of propositions grow to a high amount with no votes (just 0)
        //Solution: _nbVotes should be greater than 0
        require(_nbVotes > 0 && _nbVotes + votesCast[msg.sender]<=votingRights[msg.sender]); // Check you have enough voting rights.
        
        votesCast[msg.sender]+=_nbVotes;
        votesReceived[_proposition]+=_nbVotes;
    }
}

//*** Exercise 3 ***//
// You can buy tokens.
// The owner can set the price.
contract BuyToken {
    mapping(address => uint) public balances;
    uint public price=1;
    address public owner=msg.sender;
    
    /** @dev Buy tokens.
     *  @param _amount The amount to buy.
     *  @param _price  The price to buy those in ETH.
     */
    function buyToken(uint _amount, uint _price) payable {
        require(_price>=price); // The price is at least the current price.
        require(_price * _amount * 1 ether <= msg.value); // You have paid at least the total price.
        balances[msg.sender]+=_amount;
    }
    
    /** @dev Set the price, only the owner can do it.
     *  @param _price The new price.
     */
    function setPrice(uint _price) {
        require(msg.sender==owner);
        //Having the possibility of a 0 price allows the contract to inflate to almost infinite tokens
        //This require expects the price to be higher than 0
        require(_price > 0);
        
        price=_price;
    }
}

//*** Exercise 4 ***//
// Contract to store and redeem money.
contract Store {
    // struct Safe {
    //     address owner;
    //     uint amount;
    // }
    
    // Safe[] public oldSafes;

    mapping (address => uint) private safes;
    
    /// @dev Store some ETH.
    function store() payable {
        safes[msg.sender] += msg.value;
    }

    // /// @dev Store some ETH.
    // function oldStore() payable {
    //     oldSafes.push(Safe({owner: msg.sender, amount: msg.value}));
    // }
    
    // /// As the number of safes increases it could potentially increase the
    // /// amount of gas required to redeem your eth.
    // /// I will change this implementation to a map to avoid the loop
    // /// @dev Take back all the amount stored.
    // function oldTake() {
    //     for (uint i; i<safes.length; ++i) {
    //         Safe safe = safes[i];
    //         if (safe.owner==msg.sender && safe.amount!=0) {
    //             msg.sender.transfer(safe.amount);
    //             safe.amount=0;
    //         }
    //     }
    // }

    /// @dev Take back all the amount stored.
    function take() {
        uint amount = safes[msg.sender];
        if (amount > 0) {
            safes[msg.sender] = 0;
            msg.sender.transfer(amount);
        }
    }
}

//*** Exercise 5 ***//
// Count the total contribution of each user.
// Assume that the one creating the contract contributed 1ETH.
contract CountContribution {
    mapping(address => uint) public contribution;
    uint public totalContributions;
    address owner=msg.sender;
    
    /// @dev Constructor, count a contribution of 1 ETH to the creator.
    function CountContribution() public {
        recordContribution(owner, 1 ether);
    }
    
    /// @dev Contribute and record the contribution.
    function contribute() public payable {
        recordContribution(msg.sender, msg.value);
    }
    
    /** @dev Record a contribution. To be called by CountContribution and contribute.
     *  @param _user The user who contributed.
     *  @param _amount The amount of the contribution.
     */
     // Avoiding to specify a visibility for a function automatically defaults it to "public"
     // By being public this method can be called by anyone skipping the payable one and
     // thus defeating the purpose :).
     // Solution: Set this function to private visibility
    function recordContribution(address _user, uint _amount) private {
        contribution[_user]+=_amount;
        totalContributions+=_amount;
    }
    
}

//*** Exercise 6 ***//
contract Token {
    mapping(address => uint) public balances;
    
    /// @dev Buy token at the price of 1ETH/token.
    function buyToken() payable {
        balances[msg.sender]+=msg.value / 1 ether;
    }
    
    /** @dev Send token.
     *  @param _recipient The recipient.
     *  @param _amount The amount to send.
     */
    function sendToken(address _recipient, uint _amount) {
        require(balances[msg.sender]>=_amount); // You must have some tokens.
        
        balances[msg.sender]-=_amount;
        balances[_recipient]+=_amount;
    }
    
    /** @dev Send all tokens.
     *  @param _recipient The recipient.
     */
    function sendAllTokens(address _recipient) {
        // This is a typo. It's replacing the balances instead of adding them.
        // Solution: Convert this to a sum operator
        balances[_recipient]+=balances[msg.sender];
        balances[msg.sender]=0;
    }
    
}

//*** Exercise 7 ***//
// You can buy some object.
// Further purchases are discounted.
// You need to pay basePrice / (1 + objectBought), where objectBought is the number of object you previously bought.
contract DiscountedBuy {
    uint public basePrice = 1 ether;
    mapping (address => uint) public objectBought;

    /// @dev Buy an object.
    function buy() payable {
        //This function was unable to process by paying the amount returned by price() 3 times
        //Due to number rounding we can't have the formula the way we had it because
        //when the price is 1/3 eth there is no way to make the multiplication be equal to exactly 1 eth
        //rendering the user unable to buy the 3rd time
        //Solution: Validate the require with the exact formula that price() provides
        require(msg.value == (basePrice / (1 + objectBought[msg.sender])));
        //require(msg.value * (1 + objectBought[msg.sender]) == basePrice);
        objectBought[msg.sender]+=1;
    }
    
    /** @dev Return the price you'll need to pay.
     *  @return price The amount you need to pay in wei.
     */
    function price() constant returns(uint price) {
        return basePrice/(1 + objectBought[msg.sender]);
    }
    
}

//*** Exercise 8 ***//
// You choose Head or Tail and send 1 ETH.
// The next party send 1 ETH and try to guess what you chose.
// If it succeed it gets 2 ETH, else you get 2 ETH.

//The guess info is visible in the blockchain. For this contract to work the approach
//needs to be altered in a way that the value to be guesses can't be exposed. 
//One way I suggest is for it to become in 3 steps:
//1) The chooser sends a bytes32 which is hash(password, choice) where password is a secret word
//2) The guesser sends his/her guess
//3) The chooser calls a 3rd function sending the password clearly, then the evm validates hash(password, guesser's choice) to see if it matches
//
//Of course this leaves another vulnerability: The chooser being reluctant to call the 3rd function if he/she knows he lost.
//That can be worked around, perhaps with a timeout
contract HeadOrTail {
    bool public chosen; // True if head/tail has been chosen.
    bool lastChoiceHead; // True if the choice is head.
    address public lastParty; // The last party who chose.
    
    /** @dev Must be sent 1 ETH.
     *  Choose head or tail to be guessed by the other player.
     *  @param _chooseHead True if head was chosen, false if tail was chosen.
     */
    function choose(bool _chooseHead) payable {
        require(!chosen);
        require(msg.value == 1 ether);
        
        chosen=true;
        lastChoiceHead=_chooseHead;
        lastParty=msg.sender;
    }
    
    
    function guess(bool _guessHead) payable {
        require(chosen);
        require(msg.value == 1 ether);
        
        if (_guessHead == lastChoiceHead)
            msg.sender.transfer(2 ether);
        else
            lastParty.transfer(2 ether);
            
        chosen=false;
    }
}

//*** Exercise 9 ***//
// You can store ETH in this contract and redeem them.
contract Vault {
    mapping(address => uint) public balances;

    /// @dev Store ETH in the contract.
    function store() payable {
        balances[msg.sender]+=msg.value;
    }
    
    /// @dev Redeem your ETH.
    function redeem() {
        //This was subject to a vulnerability regarding msg.sender being another contract
        //and exploiting the fact that balances[msg.sender] is still not 0 at that point
        uint _balance = balances[msg.sender];
        require(_balance > 0);
        balances[msg.sender]=0;
        msg.sender.transfer(_balance);
//        msg.sender.call.value(balances[msg.sender])();
    }
}

//*** Exercise 10 ***//
// You choose Head or Tail and send 1 ETH.
// The next party send 1 ETH and try to guess what you chose.
// If it succeed it gets 2 ETH, else you get 2 ETH.
contract HeadTail {
    address public partyA;
    address public partyB;
    bytes32 public commitmentA;
    bool public chooseHeadB;
    uint public timeB;
    
    
    
    /** @dev Constructor, commit head or tail.
     *  @param _commitmentA is keccak256(chooseHead,randomNumber);
     */
    function HeadTail(bytes32 _commitmentA) payable {
        require(msg.value == 1 ether);
        
        commitmentA=_commitmentA;
        partyA=msg.sender;
    }
    
    /** @dev Guess the choice of party A.
     *  @param _chooseHead True if the guess is head, false otherwize.
     */
    function guess(bool _chooseHead) payable {
        require(msg.value == 1 ether);
        //The contract doesn't limit the amount of guesses so it can be exposed to the following:
        //1) another party being able to guess on top of someone else's guess and rendering old partyB unable to win or lose because his/her state was overwritten by someone else's guess
        //2) There is a small window of time where partyB can scan the transactions looking for a resolve() call and respond with a call to guess() with the right choice but higher gas in order to be considered first
        //Solution: Limit the call to guess()
        require(timeB > 0);
        
        chooseHeadB=_chooseHead;
        timeB=now;
        partyB=msg.sender;
    }
    
    /** @dev Reveal the commited value and send ETH to the winner.
     *  @param _chooseHead True if head was chosen.
     *  @param _randomNumber The random number chosen to obfuscate the commitment.
     */
    function resolve(bool _chooseHead, uint _randomNumber) {
        require(msg.sender == partyA);
        require(keccak256(_chooseHead, _randomNumber) == commitmentA);
        require(this.balance >= 2 ether);
        
        if (_chooseHead == chooseHeadB)
            partyB.transfer(2 ether);
        else
            partyA.transfer(2 ether);
    }
    
    /** @dev Time out party A if it takes more than 1 day to reveal.
     *  Send ETH to party B.
     * */
    function timeOut() {
        require(now > timeB + 1 days);
        require(this.balance>=2 ether);
        partyB.transfer(2 ether);
    }
    
}

//*** Exercise 11 ***//
// You can store ETH in this contract and redeem them.
contract VaultInvariant {
    mapping(address => uint) public balances;
    uint totalBalance;

    /// @dev Store ETH in the contract.
    function store() payable {
        balances[msg.sender]+=msg.value;
        totalBalance+=msg.value;
    }
    
    /// @dev Redeem your ETH.
    function redeem() {
        uint toTranfer = balances[msg.sender];
        msg.sender.transfer(toTranfer);
        balances[msg.sender]=0;
        totalBalance-=toTranfer;
    }
    
    /// @dev Let a user get all funds if an invariant is broken.
    
    ///Working with this.balance is dangerous. The following contract called VaultInvariantBreaker
    ///If deployed given VaultInvariant's address will render it in an invariant state
    ///Allowing anyone to call invariantBroken and clearing it's balance
    function invariantBroken() {
        require(totalBalance!=this.balance);
        
        msg.sender.transfer(this.balance);
    }
}


contract VaultInvariantBreaker {
    function VaultInvariantBreaker(address vlt) payable {
        require(msg.value > 0);
        selfdestruct(vlt);
    }
}