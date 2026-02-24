# Challenge #2 - Naive Receiver

There's a lending pool offering quite expensive flash loans of Ether, which has 1000 ETH in balance.

You also see that a user has deployed a contract with 10 ETH in balance, capable of interacting with the lending pool and receiving flash loans of ETH.

Drain all ETH funds from the user's contract. Doing it in a single transaction is a big plus 😉

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/naive-receiver)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/naive-receiver/NaiveReceiver.t.sol)

---

## Vulnerability Analysis

The vulnerability in the `NaiveReceiver` architecture stems from a severe lack of authorization handling in two core components:

1. **Unauthenticated Flash Loans (`NaiveReceiverPool.sol`)**: The `flashLoan` function fails to verify whether the entity initiating the transaction is actually the `receiver` executing the loan. Consequently, any malicious actor can relentlessly trigger flash loans on behalf of the victim (`FlashLoanReceiver`), forcing them to continuously pay the 1 WETH fixed fee until their balance is completely drained.
2. **Meta-Transaction `_msgSender()` Spoofing (`Multicall.sol` & `BasicForwarder.sol`)**: The pool implements ERC-2771-like meta-transactions to support gasless interactions via a `trustedForwarder`. The `_msgSender()` override extracts the caller's identity by reading the last 20 bytes of `msg.data`. However, the `Multicall` functionality (`delegatecall`) preserves the `msg.sender` as the `trustedForwarder` across all sub-calls in the batch. As a result, an attacker can construct an arbitrary payload appending any address of their choosing—such as the `feeReceiver`'s or the pool deployer's—effectively bypassing the access controls of the `withdraw()` function to drain the entire pool.

## The Exploit Path

The exploitation process requires two main phases executed atomically within a single meta-transaction payload:

1. **Draining the Receiver:** Formulate an array of 10 identical calls to `pool.flashLoan()` targeting the `FlashLoanReceiver`. Because the fee is 1 WETH per loan and the receiver has 10 WETH, these 10 calls gracefully syphon all funds out of the victim's contract and into the pool's designated `feeReceiver` tracking variable.
2. **Draining the Pool:** Utilize the flawed `_msgSender()` logic to execute unauthorized `withdraw()` operations. Since the funds now sit across two different logical deposits within the pool—10 WETH owned by the `feeReceiver` and the original 1000 WETH owned by the deployer—we must inject forged addresses at the end of the `multicall` calldatas. We append the `feeReceiver` address to withdraw the fees, and `address(this)` (the test contract deployer) to withdraw the principal collateral.
3. **Meta-Transaction Execution:** Bundle the 12 calls via `multicall`, structure an EIP-712 `BasicForwarder.Request`, sign it with a valid private key, and invoke `forwarder.execute()`. 

## Proof of Concept (PoC)

During the resolution of this challenge and the development of the PoC, three specific engineering hurdles were tackled to achieve a fully functional exploit:

1. **Struct Scope Resolution:** Initially, the compiler reverted with an `Identifier not found` error regarding the `Request` struct. This was resolved by explicitly referencing the parent contract scope (`BasicForwarder.Request`) within `NaiveReceiver.t.sol`.
2. **Signature Type Mismatches:** The Foundry cheat code `vm.sign` strictly requires a `uint256` private key, whereas the boilerplate provided an `address payable` (the attacker). This constraint was satisfied by switching the boilerplate user generation back to `makeAddrAndKey("Attacker")`, effectively capturing both the `attacker` address and its corresponding private signer key (`attackerPk`).
3. **Execution Panics and the Dual-Withdrawal Solution:** A naive approach to the multicall payload assumed all 1010 WETH could be withdrawn by spoofing the `feeReceiver`. This caused an arithmetic underflow (`0x11` panic) during the `Multicall` delegate call, because the `feeReceiver` was only credited with the 10 WETH accrued from the flash loans—not the initial 1000 WETH deposit. The solution involved dissecting the withdrawal payload into two parallel instructions: one simulating the `feeReceiver` for 10 WETH, and another simulating `address(this)` for 1000 WETH.

## Remediation

To comprehensively mitigate these critical flaws, the architecture must be rectified on both fronts:

1. **Restrict Flash Loan Initiators:** Modify the `flashLoan()` function within `NaiveReceiverPool.sol` to enforce that only the intended borrower or a whitelisted smart contract can request the loan. Alternatively, implement a pull-based approval system where the receiver must cryptographically authorize flash loans requested by third parties.
```solidity
if (msg.sender != address(receiver)) revert UnauthorizedBorrower();
```
2. **Secure the Multicall & Forwarder Implementation:** The overriding of `_msgSender()` should never be implicitly trusted downstream in a `delegatecall` context like `Multicall`, as `msg.data` can be arbitrarily packed with padding. A robust solution implies refactoring the `Multicall` logic to strip or validate the appended sender data, or adhering strictly to the OpenZeppelin `ERC2771Context` which mitigates payload manipulation vectors.
