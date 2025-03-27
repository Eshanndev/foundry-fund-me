//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.sol";

contract TestFundMe is Test{
  
  DeployFundMe deployFundMe = new DeployFundMe();
  FundMe fundMe;

  address USER = makeAddr("user");
  
  uint256 SEND_VALUE = 0.1 ether;
  uint256 STARTING_BALANCE = 100 ether;

  
  
  
  

  function setUp()external{
    fundMe = deployFundMe.run();
    vm.deal(USER,STARTING_BALANCE);

    
  }



  //test functions are below


  
  function testMinimumUsd()public view {
    uint256 minimumUsd = fundMe.getMinimumUsd();
    assertEq(minimumUsd , 5e18);
  }

  function testOwner()public view {
    address owner = fundMe.getOwner();
    assertEq(owner , msg.sender);
  }

  function testFundMe_PriceFeedIsAccurate()public view{
    address priceFeedAddress= fundMe.getPriceFeedAddress();
    console.log(priceFeedAddress);
  }


  //funded modifier

  modifier funded(){
    vm.prank(USER);
    fundMe.Fund{value:SEND_VALUE}();
    _;
  }





  //below here are testing funding function and etc

  function testFund_depositRevertIfBelowMinimumAmount()public {
    vm.prank(USER);
    vm.expectRevert();
    fundMe.Fund();
  }
  

  function testFundMe_depositSuccessIfAboveMinimumAmount() public{
    
    vm.prank(USER);//next line will trigger by this address
    fundMe.Fund{value: SEND_VALUE}();
    
    uint256 fundedAmount  = fundMe.getAddressToAmount(USER);
    
    assertEq(fundedAmount, SEND_VALUE);

  }

  function testFundMe_fundersArrayIsUpdating()public {
    vm.prank(USER);
    fundMe.Fund{value:SEND_VALUE}();
    assertEq(fundMe.getFunder(0), USER);
  }


  //testing withdraw process

  function testFundMe_withdrawRejectWhenUser() public funded{
    vm.prank(USER);
    vm.expectRevert();
    fundMe.withdraw();

  }

  function testFundMe_withdrawSuccessWhenOwner()public funded{
    address owner = fundMe.getOwner();
    uint256 startingOwnerBalance = owner.balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.prank(owner);
    fundMe.withdraw();

    assertEq(address(fundMe).balance, 0);
    assertEq(owner.balance , startingOwnerBalance + startingFundMeBalance);
  }

  function testFundMe_withdrawFromMultipleFunders() public {
    //create some addresses
    //fund from them
    //try withdrawing
    address owner = fundMe.getOwner();
    uint160 funderIndex;
    for (funderIndex = 1; funderIndex <10; funderIndex++){
      address funder = address(funderIndex);
      hoax(funder ,SEND_VALUE);
      fundMe.Fund{value:SEND_VALUE}();
    }

    uint256 startingOwnerBalance = owner.balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.prank(owner);
    fundMe.withdraw();


    assertEq(address(fundMe).balance,0);
    assertEq(owner.balance, startingOwnerBalance + startingFundMeBalance);

  }

}