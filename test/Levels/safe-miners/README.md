# Challenge #13 - Safe miners
Somebody has sent +2 million DVT tokens to 0x79658d35aB5c38B6b988C23D02e0410A380B8D5c. But the address is empty, isn't it?

To pass this challenge, you have to take all tokens out.

You may need to use prior knowledge, safely.

[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/safe-miners/SafeMiners.t.sol)

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
