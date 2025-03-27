//SPDX-License-Identifier:MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

  //initial state variables

  uint256 public constant  SEPOLIA_CHAIN_ID = 11155111;
  uint256 public constant  ETH_CHAIN_ID = 1;
  address public constant  SEPOLIA_PRICE_FEED_ADDRESS = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
  address public constant  MAINNET_PRICE_FEED_ADDRESS = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

  uint8 public constant  DECIMALS = 8;
  int256 public constant  INITIAL_VALUE = 2000e8;


  struct networkConfig{
    address priceFeed;
  }

  networkConfig public activeNetworkConfig;


  constructor(){
    if(block.chainid == SEPOLIA_CHAIN_ID){
      activeNetworkConfig = getSepoliaEthConfig();
    }
    else if (block.chainid == ETH_CHAIN_ID){
      activeNetworkConfig = getEthMainnetConfig();
    }
    else {
      activeNetworkConfig = getOrCreateAnvilEthConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns(networkConfig memory){
    networkConfig memory sepoliaEthConfig = networkConfig({priceFeed:SEPOLIA_PRICE_FEED_ADDRESS});
    return sepoliaEthConfig;
  }

  function getEthMainnetConfig()public pure returns(networkConfig memory){
    networkConfig memory mainnetEthConfig = networkConfig({priceFeed:MAINNET_PRICE_FEED_ADDRESS});
    return mainnetEthConfig;
  }

  

  function getOrCreateAnvilEthConfig()public returns(networkConfig memory){

    if (activeNetworkConfig.priceFeed != address(0)){
      return activeNetworkConfig;
    }
    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed =  new MockV3Aggregator(DECIMALS, INITIAL_VALUE);
    vm.stopBroadcast();

    networkConfig memory anvilEthConfig = networkConfig({priceFeed:address(mockPriceFeed)});
    return anvilEthConfig;
  }

}