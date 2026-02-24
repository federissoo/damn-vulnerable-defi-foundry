# Challenge #11 - Backdoor
To incentivize the creation of more secure wallets in their team, someone has deployed a registry of [Gnosis Safe wallets](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/GnosisSafe.sol). When someone in the team deploys and registers a wallet, they will earn 10 DVT tokens.

To make sure everything is safe and sound, the registry tightly integrates with the legitimate [Gnosis Safe Proxy Factory](https://github.com/safe-global/safe-contracts/blob/v1.3.0/contracts/proxies/GnosisSafeProxyFactory.sol), and has some additional safety checks.

Currently there are four people registered as beneficiaries: Alice, Bob, Charlie and David. The registry has 40 DVT tokens in balance to be distributed among them.

Your goal is to take all funds from the registry. In a single transaction.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/backdoor)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/backdoor/Backdoor.t.sol)

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
