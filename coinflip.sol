pragma solidity ^0.4.20;
contract Coinflipping {
  address public player1;
  address public player2;
  uint public wager;
  uint public seedBlockNumber;
  enum GameState {noWager, wagerMadeByPlayer1, wagerAccepted}
  GameState public currentState;

  function Coinflipping() public payable {
    currentState = GameState.noWager;
  }

  function makeWager() public payable {
    if (currentState == GameState.noWager) {
      if (msg.value >= 1e18) {
        player1 = msg.sender;
        wager = msg.value;
        currentState = GameState.wagerMadeByPlayer1;
      } else {
        msg.sender.transfer(msg.value);
      }
    } else {
      msg.sender.transfer(msg.value);
    }
  }

  function acceptWager() public payable {
    if (currentState == GameState.wagerMadeByPlayer1) {
      if (msg.value == wager) {
        player2 = msg.sender;
        currentState = GameState.wagerAccepted;
        seedBlockNumber = block.number;
      } else {
        msg.sender.transfer(msg.value);
      }
    } else {
      msg.sender.transfer(msg.value);
    }
  }

  function resolve() public {
    uint256 blockValue = uint256(block.blockhash(seedBlockNumber));
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968; //2^256/2
    uint256 coinFlip = uint256(blockValue / FACTOR);

    if (coinFlip == 0) {
      player1.transfer(this.balance);
    } else {
      player2.transfer(this.balance);
    }
    currentState = GameState.noWager;
  }

  function getState() public returns (string) {
    if (currentState == GameState.noWager) {
      return "no wager";
    } else if (currentState == GameState.wagerMadeByPlayer1) {
      return "wager made by first player";
    } else {
      return "wager was accepted";
    }
  }

  function kill() public {                 
    if (currentState == GameState.wagerMadeByPlayer1 && msg.sender == player1) {
      selfdestruct(player1); 
    }
  }

}