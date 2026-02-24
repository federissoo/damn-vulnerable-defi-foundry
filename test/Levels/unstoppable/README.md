# Challenge #1 - Unstoppable
There's a lending pool with a million DVT tokens in balance, offering flash loans for free.

If only there was a way to attack and stop the pool from offering flash loans ...

You start with 100 DVT tokens in balance.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/unstoppable)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/unstoppable/Unstoppable.t.sol)

## Vulnerability Analysis
The vulnerability lies in the `flashLoan` function of the `UnstoppableLender` contract, specifically in the strict equality check:

```solidity
if (poolBalance != balanceBefore) revert AssertionViolated();
```

The contract tracks the pool's balance in a state variable `poolBalance`, which is only updated when `depositTokens` is called. However, it also checks `balanceBefore` using `damnValuableToken.balanceOf(address(this))`. 

If an attacker sends tokens directly to the contract (bypassing `depositTokens`), `balanceBefore` will increase, but `poolBalance` will remain the same. This mismatch causes the `AssertionViolated` revert, effectively causing a Denial of Service (DoS) for the flash loan functionality.

## The Exploit Path

Step 1: The attacker obtains DVT tokens (100 DVT in this scenario).

Step 2: The attacker transfers these tokens directly to the `UnstoppableLender` contract using the ERC20 `transfer` function.

Step 3: This direct transfer increases the contract's actual token balance without updating the `poolBalance` state variable.

Step 4: Any subsequent call to `flashLoan` will fail because `poolBalance != balanceBefore`, rendering the contract unusable.

## Proof of Concept (PoC)
Here is the exploit code used in `Unstoppable.t.sol`:

```solidity
function testExploit() public {
    /**
     * EXPLOIT START *
     */
    // Transer tokens directly to the lender contract to break the accounting
    dvt.transfer(address(unstoppableLender), 100e18);
    /**
     * EXPLOIT END *
     */
    vm.expectRevert(UnstoppableLender.AssertionViolated.selector);
    validation();
    console.log(unicode"\n🎉 Congratulations, you can go to the next level! 🎉");
}
```

## Remediation (Fondamentale)
The strict equality check `poolBalance == balanceBefore` is dangerous because the contract cannot control who sends it tokens. 

To fix this:
1.  **Remove the separate `poolBalance` tracking**: Rely solely on `damnValuableToken.balanceOf(address(this))`.
2.  **Use `>=` instead of `==`**: If you must track deposited balance, ensure `balanceBefore >= poolBalance`. However, logic relying on exact balances is generally discouraged for this reason.

Recommended implementation:
```solidity
// Remove poolBalance state variable and logic
function flashLoan(uint256 borrowAmount) external nonReentrant {
    if (borrowAmount == 0) revert MustBorrowOneTokenMinimum();

    uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
    if (balanceBefore < borrowAmount) revert NotEnoughTokensInPool();

    // ... execute loan ...

    uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
    if (balanceAfter < balanceBefore) revert FlashLoanHasNotBeenPaidBack();
}
```

## Personal Note
This challenge took me a bit longer than expected because it was my first time approaching tokens, flash loans, and liquidity pools. I had to research and understand the basic mechanics of how these components interact before I could identify how a simple direct transfer could break the contract's accounting logic.

I strongly prefer a **learning by doing** approach. Even though I started without a clear understanding of these concepts, diving directly into the code allowed me to assimilate them 10x faster than just studying the theory.
