pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/wag_backend/blob/main/more/CasinoStandard.sol";
contract TwelveNumbers is CS{
    mapping(uint=>Room)private room;
    mapping(uint=>Room)private roomHistory;
    mapping(address=>Player)private player;
    constructor(address a){
        (iwag,_owner)=(a,msg.sender);
    }
    struct Player{
        uint[]room;
        uint[]number;
    }
    struct Room{
        uint winningNum;
        uint[]numbers;
        address[]players;
    }
    function BET(uint a,uint b)external{unchecked{ //Room bet size = room number
        require(room[a].players.length<13);
        require(b<13);
        IWAG(iwag).BURN(msg.sender,a*1e18);
        player[msg.sender].room.push(a);
        player[msg.sender].number.push(b);
        room[a].players.push(msg.sender);
        room[a].numbers.push(b);
        if(room[a].players.length>11){
            uint winNum=room[a].numbers[uint(keccak256(abi.encodePacked(block.timestamp,block.coinbase)))%12];
            (roomHistory[a]=room[a],roomHistory[a].winningNum=winNum,b=0);
            delete room[a];
            for(uint i=0;i<12;i++)if(roomHistory[a].numbers[i]==winNum)b++; //Get number of winners
            b=a*12*19/20/b*1e18;
            for(uint i=0;i<12;i++){
                if(roomHistory[a].numbers[i]==winNum)IWAG(iwag).MINT(roomHistory[a].players[i],b);
                delete player[roomHistory[a].players[i]];
            }
        }
    }}
    function GetPlayer(address a)external view returns(uint[]memory,uint[]memory){unchecked{
        return(player[a].room,player[a].number);
    }}
    function GetRoomHistory(uint a)external view returns(uint,uint[]memory,uint){
        return (roomHistory[a].winningNum,roomHistory[a].numbers,room[a].numbers.length);
    }
}