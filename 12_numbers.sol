/* DEPLOYMENT: JOIN & DEAL to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
}
contract twelve_number{
    constructor(address a){
        (iwac,_owner)=(a,msg.sender);
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
    mapping(uint=>Room)private roomHistory;
    mapping(address=>Player)private player;

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
        require(b<13);
        require(player[msg.sender].balance>=a);
        Bet memory bet;
        (player[msg.sender].balance-=a,bet.room=a,bet.number=b);
        player[msg.sender].bets.push(bet);
        room[a].players.push(msg.sender);
        room[a].numbers.push(b);
        if(room[a].players.length>11){
            uint winNum=uint(keccak256(abi.encodePacked(block.timestamp,block.coinbase)))%12+1;
            (roomHistory[a]=room[a],roomHistory[a].winningNum=winNum,b=0);
            delete room[a];
            for(uint i=0;i<12;i++)if(roomHistory[a].numbers[i]==winNum)b++; //Get number of winners
            b=a*12*19/20/b;
            for(uint i=0;i<12;i++){
                if(roomHistory[a].numbers[i]==winNum)player[roomHistory[a].players[i]].balance+=b;
                Player storage p=player[roomHistory[a].players[i]];
                for(uint j=0;j<p.bets.length;j++)if(p.bets[j].room==a){
                    p.bets[j]=p.bets[p.bets.length-1];
                    p.bets.pop();
                }
            }
        }
    }}

    function GetPlayer(address a)external view returns(uint b,uint[]memory c,uint[]memory d){unchecked{
        uint l=player[a].bets.length;
        (b,c,d)=(player[a].balance,new uint[](l),new uint[](l));
        for(uint i=0;i<l;i++)(c[i]=player[a].bets[i].room,d[i]=player[a].bets[i].number);
    }}
    function GetRoomHistory(uint a)external view returns(uint,uint[]memory){
        return (roomHistory[a].winningNum,roomHistory[a].numbers);
    }
}