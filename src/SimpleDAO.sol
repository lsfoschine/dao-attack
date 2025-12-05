// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Versão minimalista de uma DAO vulnerável a reentrancy
contract SimpleDAO {
    mapping(address => uint256) public balances;

    /// @notice Depósito simples
    function deposit() external payable {
        require(msg.value > 0, "no value");
        balances[msg.sender] += msg.value;
    }

    /// @notice Saque vulnerável (padrão "The DAO"): external call antes de atualizar o estado
    function withdraw() external {
        uint256 amount = balances[msg.sender];
        require(amount > 0, "no balance");

        // ⚠️ BUG: faz a chamada externa antes de atualizar o saldo
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "eth transfer failed");

        // Atualiza o saldo só depois — isso abre brecha para reentrancy
        balances[msg.sender] = 0;
    }

    // Helper só pra ver o saldo total no teste
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
