# Challenge #3 - Truster
More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

Currently the pool has 1 million DVT tokens in balance. And you have nothing.

But don't worry, you might be able to take them all from the pool. In a single transaction.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/truster)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/truster/Truster.t.sol)

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
