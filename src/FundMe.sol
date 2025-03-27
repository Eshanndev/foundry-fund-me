//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import {PriceConverter} from "../src/PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


//custom errrors
error FundMe__notOwner();

contract FundMe{

  using PriceConverter for uint256;



  //arrays and mappings
  address[] private s_funders;
  mapping(address=> uint256) private s_addressToAmount;



  //initial state variables
  uint256 constant private MINIMUM_USD = 5e18;
  address immutable private i_owner;
  AggregatorV3Interface private s_priceFeed;
   



  constructor(address priceFeed){
    i_owner = msg.sender;
    s_priceFeed = AggregatorV3Interface(priceFeed);//0x694AA1769357215DE4FAC081bf1f309aDC325306
  }



  //check version of price feed
  function version()public view returns(uint256){
    AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
    return priceFeed.version();
  }





  //allow anyone to fund more than 5$
  function Fund ()public payable {
    
    require(msg.value.getConversionRate(s_priceFeed) > MINIMUM_USD, "Minimum amount is 5$");
    s_funders.push(msg.sender);
    s_addressToAmount[msg.sender] += msg.value;
  }

  

  //allow owner to withdraw all funds 
  function withdraw()public onlyOwner{
    uint256 fundersLength = s_funders.length;
    for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){
      address funder = s_funders[funderIndex];
      s_addressToAmount[funder] = 0;
    }

    s_funders = new address[](0);//not sure about this double check

    (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");
    require(callSuccess,"Call failed");


  }




  //modifiers
  modifier onlyOwner {
    if(msg.sender != i_owner){
      revert FundMe__notOwner();
    }
    _;
  }

  receive()external payable{
    Fund();
  }

  fallback()external payable{
    Fund();
  }



  //getter functions

  function getAddressToAmount(address fundingAddress) public view returns(uint256){
    return s_addressToAmount[fundingAddress];
  }

  function getPriceFeedAddress()public view returns(address){
    address priceFeedAddress = address(s_priceFeed);
    return priceFeedAddress;
  }

  function getFunder(uint256 index) public view returns(address){
    address funder = s_funders[index];
    return funder;
  }

  function getOwner () public view returns(address) {
    return i_owner;
  }

  function getMinimumUsd() public pure returns(uint256){
    return MINIMUM_USD;
  }

  
  

}