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
3. **The Logical Fallacy and Arithmetic Underflow (`address(this)` vs `feeReceiver`/Deployer):** While architecting the exploit, one might be tempted to designate `address(this)` as the withdrawal recipient for the initial 1000 WETH deposit.
🚨 **This would inevitably trigger a transaction failure:**
Within the execution context of a malicious contract crafted by an attacker, `address(this)` evaluates to the *attacker's contract itself*, which has **never deposited any funds** into the pool! Its inherent balance mapped in `deposits[address(this)]` is strictly zero. Consequently, when the pool evaluates the internal logic `deposits[address(this)] -= 1000 WETH`, the subtraction of 1000 from 0 instantly throws a mathematical error (`Arithmetic Underflow`, panic code `0x11`), rendering the entire meta-transaction structurally invalid and retroactively reverting all preceding flash loans.
In the *Damn Vulnerable DeFi* ecosystem, the identity of the entity that provisions the initial 1000 WETH pool liquidity is heavily dependent on the specific challenge initialization (whether it is the underlying `feeReceiver`/Admin, or a dedicated `deployer` script). Therefore, the original administrator or depositor retains exclusive claim over the 1000 WETH credit. The correct methodology mandates decoupling the malicious operations by accurately spoofing the identities of the entities that *provably* hold the deposited credits in the mapping (e.g., spoofing the `feeReceiver` to siphon the 10 WETH fees, and mimicking the `deployer` to extract the 1000 WETH principal; alternatively, executing a single 1010 WETH withdrawal if the administrator acts as the sole liquidity provider).

## Remediation

To comprehensively mitigate these critical flaws, the architecture must be rectified on both fronts:

1. **Restrict Flash Loan Initiators:** Modify the `flashLoan()` function within `NaiveReceiverPool.sol` to enforce that only the intended borrower or a whitelisted smart contract can request the loan. Alternatively, implement a pull-based approval system where the receiver must cryptographically authorize flash loans requested by third parties.
```solidity
if (msg.sender != address(receiver)) revert UnauthorizedBorrower();
```
2. **Secure the Multicall & Forwarder Implementation:** The overriding of `_msgSender()` should never be implicitly trusted downstream in a `delegatecall` context like `Multicall`, as `msg.data` can be arbitrarily packed with padding. A robust solution implies refactoring the `Multicall` logic to strip or validate the appended sender data, or adhering strictly to the OpenZeppelin `ERC2771Context` which mitigates payload manipulation vectors.
