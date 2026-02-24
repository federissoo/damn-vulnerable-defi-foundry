# Challenge #10 - Free rider
A new marketplace of Damn Valuable NFTs has been released! There's been an initial mint of 6 NFTs, which are available for sale in the marketplace. Each one at 15 ETH.

A buyer has shared with you a secret alpha: the marketplace is vulnerable and all tokens can be taken. Yet the buyer doesn't know how to do it. So it's offering a payout of 45 ETH for whoever is willing to take the NFTs out and send them their way.

You want to build some rep with this buyer, so you've agreed with the plan.

Sadly you only have 0.5 ETH in balance. If only there was a place where you could get free ETH, at least for an instant.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/free-rider)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/free-rider/FreeRider.t.sol)

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
