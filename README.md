# ⚒️ Damn Vulnerable DeFi - Foundry Solutions

Benvenuti nel repository delle mie soluzioni per **Damn Vulnerable DeFi**, il wargame definitivo per apprendere la sicurezza offensiva degli smart contract DeFi.

## 📖 Introduzione e Scelte Tecniche
Per affrontare queste sfide, ho scelto di operare in un ambiente **Solidity-native** clonando la versione **Foundry** (https://github.com/nicolasgarcia214/damn-vulnerable-defi-foundry)). Questa versione traspone i livelli originali (nativamente in Hardhat/JavaScript) nel framework Foundry, offrendo diversi vantaggi tecnici:

* **Velocità**: Esecuzione dei test e degli exploit quasi istantanea.
* **Utility Estese**: Utilizzo del contratto `Utilities.sol` per la gestione semplificata degli indirizzi e la creazione dinamica di account di test.
* **Dipendenze Professionali**: Integrazione nativa con `ds-test`, `forge-std` per cheatcode avanzati e `openzeppelin-contracts` per le implementazioni standard.



## 🚀 Esecuzione dei Livelli
La repository è configurata per permettere un'esecuzione rapida e mirata di ogni singola sfida. È possibile utilizzare i seguenti comandi:

* **Tramite Makefile**: Eseguendo `make [NOME_LIVELLO]` (es. `make Unstoppable`).
* **Tramite Script di Shell**: Utilizzando `./run.sh [NUMERO_SFIDA]` o le prime lettere del nome del livello (es. `./run.sh 1`).
* **Comando Forge Diretto**: `forge test --match-contract [NOME] -vv`.

## 📁 Struttura della Repository
L'organizzazione dei file riflette un approccio ordinato tra codice vulnerabile e logica di attacco:

* **`src/Contracts/`**: Contiene il codice sorgente originale e vulnerabile dei protocolli DeFi.
* **`test/Levels/`**: Cartella principale per gli exploit. Ogni sfida ha una sottocartella dedicata contenente il file `[NOME_LIVELLO].t.sol`.
* **`test/utils/`**: Include `Utilities.sol`, lo strumento utilizzato per configurare scenari multi-utente complessi.

## 🛠️ Metodologia di Attacco
Per ogni livello, il processo di "hackeraggio" segue una pipeline rigorosa:

1.  **Analisi Statica**: Studio del codice sorgente in `src/` per identificare bug logici, errori di arrotondamento o controlli di accesso mancanti.
2.  **Impersonificazione**: Utilizzo dei cheatcode `vm.prank` o `vm.startPrank` per agire tramite l'account denominato `attacker`.
3.  **Implementazione dell'Exploit**: Scrittura del codice malevolo all'interno della funzione `testExploit()` tra i commenti predefiniti `EXPLOIT START` ed `EXPLOIT END`.
4.  **Validazione**: Verifica del successo dell'attacco tramite il controllo dei bilanci finali o l'attivazione di `vm.expectRevert` in caso di Denial of Service.

---

*Nota: Questo repository è a scopo puramente didattico e documenta il mio percorso di apprendimento nella security blockchain.*