//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.sol";
import {FundFundMe} from "../../script/interactions.s.sol";
import {WithdrawFundMe} from "../../script/interactions.s.sol";

contract FundMeTestIntergration is Test {

  
  FundMe fundMe;
  FundFundMe fundFundMe = new FundFundMe();
  
  uint256 STARTING_BALANCE = 100 ether;



  function setUp() external{
    DeployFundMe deployFundMe = new DeployFundMe();
    fundMe = deployFundMe.run();
    

  } 

  function testUserCanFundInteractions() public {
    
    vm.deal(address(fundFundMe) , STARTING_BALANCE);//Fund function called by FundFundMe contract
    fundFundMe.fundFundMe(address(fundMe));

    address funder = fundMe.getFunder(0); 
    
    

    assertEq(funder,address(fundFundMe));

  }

//   function testOwnerCanwithdrawInteractions() public {
//     WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
//     vm.deal(USER, STARTING_BALANCE);
//     vm.prank(USER);
//     withdrawFundMe.withdrawFundMe(address(fundMe));

//     address owner = fundMe.getOwner();
//     uint256 startingOwnerBalance = owner.balance;
//     uint256 startingFundMeBalance = address(fundMe).balance;

//     vm.prank(owner);
//     fundMe.withdraw();

//     assertEq(address(fundMe).balance, 0);
//     assertEq(owner.balance , startingOwnerBalance + startingFundMeBalance);

//   }



}