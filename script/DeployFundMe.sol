//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract DeployFundMe is Script {

  

  function run() public returns(FundMe){

    HelperConfig helperConfig = new HelperConfig();
    (address EthUsdPriceFeed) = helperConfig.activeNetworkConfig();

    vm.startBroadcast();
    FundMe fundMe = new FundMe(EthUsdPriceFeed);
    vm.stopBroadcast();
    return fundMe;
  }

}