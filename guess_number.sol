/* DEPLOYMENT: JOIN & DEAL to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
}
contract guess_number{
    constructor(address a){
        iwac=a;
        _owner=msg.sender;
        player[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db].balance=1000;
    }
    struct Bet{
        uint room;
        uint number;
    }
    struct Player{
        Bet[]bets;
        uint balance;
    }
    struct Room{
        uint winningNum;
        uint[]numbers;
        address[]players;
    }
    address private iwac;
    address private _owner;
    mapping(uint=>Room)private room;
    mapping(uint=>Room)public roomHistory;
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

    function BET(uint a,uint b)external{unchecked{ //Room bet size = room number
        require(room[a].players.length<13);
        require(player[msg.sender].balance>=a);
        if(room[a].players.length>0)require(b==room[a].numbers[0]);
        room[a].players.push(msg.sender);
        room[a].numbers.push(b);
        Bet memory bet;
        (player[msg.sender].balance-=a,bet.room=a,bet.number=b);
        player[msg.sender].bets.push(bet);
        if(room[a].players.length>12){
            uint winNum=uint(keccak256(abi.encodePacked(block.timestamp,block.coinbase)))%12+1;
            (roomHistory[a],roomHistory[a].winningNum,b)=(room[a],winNum,0);
            delete room[a];
            for(uint i=0;i<12;i++)if(roomHistory[a].numbers[i]==winNum)b++; //Get number of winners
            b=a*19/20/b;  
            for(uint i=0;i<12;i++)if(roomHistory[a].numbers[i]==winNum)player[roomHistory[a].players[i]].balance+=b;            
        }
    }}

    function GetPlayerBet(address a)external view returns(uint[]memory b,uint[]memory c){
        uint l=player[a].bets.length;
        (b,c)=(new uint[](l),new uint[](l));
        for(uint i=0;i<l;i++)(b[i]=player[a].bets[i].room,b[i]=player[a].bets[i].number);
    }
}