/* DEPLOYMENT: JOIN & DEAL to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
}
contract guess_number{
    struct Player{
        uint[]room;
        uint balance;
    }
    struct Room{
        address host; //First player automatically is host
        uint betSize;
        uint balance;
        uint startNum;
        uint endNum;
        Bets[]bets;
    }
    struct Bets{
        address player;
        uint betNum;
    }
    address private iwac;
    address private _owner;
    mapping(uint=>Room)public room;
    mapping(address=>Player)public player;






    function DEPOSIT(uint a)external{unchecked{
        player[msg.sender].balance+=a;
        IWAC(iwac).BURN(msg.sender,a);
    }}
    function WITHDRAW(uint a)external{unchecked{
        require(player[msg.sender].balance>=a);
        player[msg.sender].balance-=a;
        IWAC(iwac).MINT(msg.sender,a);
    }}
}