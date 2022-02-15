// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
contract Lottery is VRFConsumerBase {
    address public owner;
    address payable[] public players;
    uint public lotteryId;
    mapping (uint => address payable)  public lotteryHistory ; 
    bytes32 internal keyHash;// identfies which chinlink oracle to use
    uint256 internal fee;    // fee to get random number
    uint256 public randomResult;

    
    constructor() 
    VRFConsumerBase(
        0xb3dCcb4Cf7a26f6cf6B120Cf5A73875B7BBc655B, //VRF coordinator
        0x01BE23585060835E02B77ef475b0Cc51aA1e0709  // LINK token address
    ){  
        owner = msg.sender;
        lotteryId = 1;
        keyHash = 0x2ed0feb3e7fd2022120aa84fab1945545a9f2ffc9076fd6156fa96eaff4c1311;
        fee =  fee = 0.1 * 10 ** 18;  // 0.1 LINK        
        }

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    function getRandomNumber() public returns(bytes32 requestId){

        require(LINK.balanceOf(address(this)) > fee , "Not enogh fee for randomNumber");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;

        payWinner();
    }

    function enter() public payable {
        require(msg.value > 0.01 ether);
        
        //address players enter the lottery
        players.push(payable(msg.sender));

    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getPlayers() public view returns(address payable[] memory){
        return players;
    }

    //function getRandomNumber() public view returns(uint) {
    //    return uint(keccak256(abi.encodePacked(owner , block.timestamp)));
    //} 

    function pickWinner()  public onlyOwner{
        getRandomNumber();
    }
    function payWinner() public payable onlyOwner{
        uint index = randomResult % players.length;

        players[index].transfer(address(this).balance);
        
        lotteryHistory[lotteryId] = players[index];
        lotteryId++;

        players =new address payable[](0);

    }

    //function withrow() public payable 
}