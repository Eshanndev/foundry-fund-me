//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 0.01 ether;

    function fundFundMe(address mostRecentDeployed) public {
        FundMe(payable(mostRecentDeployed)).Fund{value: SEND_VALUE}();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostRecentDeployed) public {
        FundMe(payable(mostRecentDeployed)).withdraw();

    }

    function getOwner()public returns(address){
      HelperConfig helperConfig = new HelperConfig();
      HelperConfig.networkConfig memory config = helperConfig.getActiveNetworkConfig();
      return config.account;
    }

    function run() external {
        //withdraw function only can be called by owner
        address owner = getOwner();
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast(owner);
        withdrawFundMe(mostRecentDeployed);
        vm.stopBroadcast();
    }
}
