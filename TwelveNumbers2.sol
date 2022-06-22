pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"more/CasinoStandard.sol";
contract TwelveNumbers is CS{
    mapping(address=>mapping(uint=>Room))private room;
    mapping(address=>mapping(uint=>Room))private roomHistory;
    mapping(address=>mapping(address=>Player))private player;
    constructor()CS(){}
    struct Player{
        uint[]room;
        uint[]number;
    }
    struct Room{
        uint winningNum;
        uint[]numbers;
        address[]players;
    }
    function BET(address _a,uint a,uint b)external{unchecked{ //Room bet size = room number
        (Room storage r,Room storage r2,Player storage p)=(room[_a][a],roomHistory[_a][a],player[_a][msg.sender]);
        require(r.players.length<13);
        require(b<13);
        I20(_a).BURN(msg.sender,a*1e18);
        p.room.push(a);
        p.number.push(b);
        r.players.push(msg.sender);
        r.numbers.push(b);
        if(r.players.length>11){
            uint winNum=r.numbers[uint(keccak256(abi.encodePacked(block.timestamp,block.coinbase)))%12];
            (r2=r,r2.winningNum=winNum,b=0);
            delete room[_a][a];
            for(uint i=0;i<12;i++)if(r2.numbers[i]==winNum)b++; //Get number of winners
            b=a*12*19/20/b*1e18;
            for(uint i=0;i<12;i++){
                if(r2.numbers[i]==winNum)I20(_a).MINT(r2.players[i],b);
                delete player[_a][r2.players[i]];
            }
        }
    }}
    function GetPlayer(address _a,address a)external view returns(uint[]memory,uint[]memory){unchecked{
        return(player[_a][a].room,player[_a][a].number);
    }}
    function GetRoomHistory(address _a,uint a)external view returns(uint,uint[]memory,uint){
        return (roomHistory[_a][a].winningNum,roomHistory[_a][a].numbers,room[_a][a].numbers.length);
    }
}