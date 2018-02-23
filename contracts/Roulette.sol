pragma solidity ^0.4.11;

contract Roulette {
	address owner;
	uint public minimumBet = 100 finney;
	uint public totalBet;
	uint public numberOfBets;
	uint public maxAmountOfBets = 10;
	uint public numberWinner;
	address[] public players;

	mapping(address => uint) playerBetsNumber;

	struct Player {
	 	uint amountBet;
	 	uint numberSelected;
	}

	modifier onEndGame(){
	      if(numberOfBets >= maxAmountOfBets) _;
	}

	mapping(address => Player) playerInfo;

	function Roulette(uint _minimumBet){
		owner = msg.sender;
		if(_minimumBet != 0) minimumBet = _minimumBet;
	}

	// payable defines a function that can only be run by paying Ether.
	function bet(uint number) payable {
		assert(checkPlayerExists(msg.sender) == false);
		assert(number >= 1 && number <= 10);
		assert(msg.value >= minimumBet);

		playerInfo[msg.sender].amountBet = msg.value;
		playerInfo[msg.sender].numberSelected = number;
		numberOfBets += 1;
		players.push(msg.sender);
		totalBet += msg.value;

		if(numberOfBets >= maxAmountOfBets) generateNumberWinner();
	}

	function generateNumberWinner() {
		uint numberGenerated = block.number % 10 + 1;
		distributePrizes(numberGenerated);
	}

	function distributePrizes(uint numberWinner) {
		address[10] memory winners; // memory array is deleted after function has executed.
		uint count = 0;

		for(uint i = 0; i < players.length; i++) {
			address playerAddress = players[i];
			if(playerInfo[playerAddress].numberSelected == numberWinner) {
				winners[count] = playerAddress;
				count++;
			}
			delete playerInfo[playerAddress];
		}

		players.length = 0; //delete the players in array.

		uint winnerEtherAmount = totalBet / winners.length;

		for(uint j = 0; j < count; j++) {
			if(winners[j] != address(0))
			winners[j].transfer(winnerEtherAmount);
		}
	}

	function checkPlayerExists(address player) constant returns(bool) {
		for (uint i = 0; i < players.length; i++) {
			if(players[i] == player) return true;
		}
		return false;
	}

	function kill(){
		if(msg.sender == owner)
		selfdestruct(owner);
	}

	function resetData(){
	   players.length = 0; // Delete all the players array
	   totalBet = 0;
	   numberOfBets = 0;
	}

	function() payable {
		//Fallback function to store any retrieved funds.
	}
}
