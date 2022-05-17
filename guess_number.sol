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

    function JOIN(uint a,uint b)public{unchecked{
        if(room[a].host==address(0)){ //Initiate the room
            require(b>4);
            room[a].betSize=b;
            room[a].host=msg.sender;
        }
        require(player[msg.sender].balance>=room[a].betSize); //Have money to bet
        require(room[a].playerCount<5); //Not full
        require(player[msg.sender].room!=a); //Not same room
        require(a>0); //Not reserved room
        room[a].players.push(msg.sender); //Add a player
        (room[a].playerCount++,player[msg.sender].room=a); //In case player disconnect
    }}




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