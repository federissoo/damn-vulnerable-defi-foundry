# Challenge #8 - Puppet
There's a huge lending pool borrowing Damn Valuable Tokens (DVTs), where you first need to deposit twice the borrow amount in ETH as collateral. The pool currently has 100000 DVTs in liquidity.

There's a DVT market opened in an [Uniswap v1 exchange](https://docs.uniswap.org/contracts/v1/overview), currently with 10 ETH and 10 DVT in liquidity.

Starting with 25 ETH and 1000 DVTs in balance, you must steal all tokens from the lending pool.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/puppet)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/puppet/Puppet.t.sol)

## Vulnerability Analysis
Non dire solo "il bug è qui". Spiega la logica. "Il contratto si fida dell'oracolo X, ma non tiene conto che il prezzo può essere manipolato tramite un Flash Loan nello stesso blocco".

## The Exploit Path
Descrivi i passi del tuo attacco.

Step 1: Prendo il prestito.

Step 2: Gonfio il prezzo.

Step 3: Svuoto il pool.

## Proof of Concept (PoC)
Il codice deve essere pulito e commentato. Se usi Foundry, scrivi dei test chiari che mostrino il bilancio prima e dopo l'attacco.

## Remediation (Fondamentale)
A Trail of Bits non piace solo chi rompe, ma chi sa come riparare. Aggiungi sempre una sezione: "Come avrei scritto questo contratto per evitare l'attacco?". (Es. usare un oracolo TWAP, aggiungere un check di reentrancy, ecc.).
