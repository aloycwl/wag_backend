pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/wag_backend/blob/main/more/CasinoStandard.sol";
contract TwelveNumbers is CS{
    mapping(uint=>Room)private room;
    mapping(uint=>Room)private roomHistory;
    mapping(address=>Player)private player;
    constructor(address a){
        (iwag,_owner)=(a,msg.sender);
    }
    struct Bet{
        uint room;
        uint number;
    }
    struct Player{
        Bet[]bets;
    }
    struct Room{
        uint winningNum;
        uint[]numbers;
        address[]players;
    }
    function BET(uint a,uint b)external{unchecked{ //Room bet size = room number
        require(room[a].players.length<13);
        require(b<13);
        Bet memory bet;
        IWAG(iwag).BURN(msg.sender,a*1e18);
        (bet.room=a,bet.number=b);
        player[msg.sender].bets.push(bet);
        room[a].players.push(msg.sender);
        room[a].numbers.push(b);
        if(room[a].players.length>11){
            uint winNum=uint(keccak256(abi.encodePacked(block.timestamp,block.coinbase)))%12+1;
            (roomHistory[a]=room[a],roomHistory[a].winningNum=winNum,b=0);
            delete room[a];
            for(uint i=0;i<12;i++)if(roomHistory[a].numbers[i]==winNum)b++; //Get number of winners
            b=a*12*19/20/b*1e18;
            for(uint i=0;i<12;i++){
                if(roomHistory[a].numbers[i]==winNum)IWAG(iwag).MINT(roomHistory[a].players[i],b);
                Player storage p=player[roomHistory[a].players[i]];
                for(uint j=0;j<p.bets.length;j++)if(p.bets[j].room==a){
                    p.bets[j]=p.bets[p.bets.length-1];
                    p.bets.pop();
                }
            }
        }
    }}
    function GetPlayer(address a)external view returns(uint[]memory b,uint[]memory c){unchecked{
        uint l=player[a].bets.length;
        (b,c)=(new uint[](l),new uint[](l));
        for(uint i=0;i<l;i++)(b[i],c[i])=(player[a].bets[i].room,player[a].bets[i].number);
    }}
    function GetRoomHistory(uint a)external view returns(uint,uint[]memory){
        return (roomHistory[a].winningNum,roomHistory[a].numbers);
    }
}