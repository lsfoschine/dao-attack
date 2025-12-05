# Reentrância inspirada na The DAO com Foundry

Reprodução de um ataque de reentrância semelhante ao ocorrido na The DAO, utilizando contratos simples em Solidity e testes automatizados com Foundry.

## Estrutura

- `src/SimpleDAO.sol`  
  Contrato vulnerável, que permite saque reentrante ao enviar ETH antes de atualizar o saldo interno.

- `src/Attacker.sol`  
  Contrato atacante que explora a vulnerabilidade chamando `withdraw()` recursivamente via `receive()`.

- `test/DaoAttack.t.sol`  
  Teste Foundry que:
  - configura um cenário com uma vítima que deposita 10 ETH na DAO
  - executa o ataque
  - verifica que o atacante termina com mais ETH do que depositou e que a DAO é quase drenada

- `test/ForkInfo.t.sol`  
  Teste auxiliar que exibe `block.chainid` e `block.number` para evidenciar a execução em fork da mainnet.

## Como rodar os testes (EVM local)

```bash
forge test -vv
```

## Como rodar com local fork da mainnet

```bash
MAINNET_RPC_URL=https://ethereum-rpc.publicnode.com
forge test --fork-url $MAINNET_RPC_URL -vv
```