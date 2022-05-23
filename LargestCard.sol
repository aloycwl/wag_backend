/* DEPLOYMENT: JOIN to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/wag_backend/blob/main/more/CasinoStandard.sol";
contract LargestCard is CS{
    struct Player{
        uint card;
        uint points;
        uint room;
    }
    struct Room{
        address[]players; //First player automatically is host
        uint betSize;
    }
    mapping(uint=>Room)public room;
    mapping(address=>Player)public player;
    constructor(address a){unchecked{
        (iwag=a,_owner=msg.sender);
    }}
    /*function DEPOSIT(uint a)external{unchecked{
        player[msg.sender].balance+=a;
        IWAC(iwac).BURN(msg.sender,a);
    }}
    function WITHDRAW(uint a)external{unchecked{
        require(player[msg.sender].balance>=a);
        player[msg.sender].balance-=a;
        IWAC(iwac).MINT(msg.sender,a);
    }}*/
    function JOIN(uint a,uint b)public{unchecked{
        if(room[a].players.length<1){
            require(b>9);
            room[a].betSize=b*1*18;
        }
        require(IWAG(iwag).balanceOf(msg.sender)>=room[a].betSize); //Have money to bet
        require(room[a].players.length<20); //Not full
        require(player[msg.sender].room!=a); //Not same room
        require(a>0); //Not reserved room
        room[a].players.push(msg.sender); //Add a player
        player[msg.sender].room=a; //In case player disconnect
    }}
    function LEAVE(uint a,address b)public{unchecked{ //Only host can kick
        require(player[msg.sender].room==a||msg.sender==room[player[b].room].players[0]);
        player[b].room=0;
        if(room[a].players.length==1)delete room[a]; //Delete room if no more player
        else{
            uint c; //Move players up
            for(uint i=0;i<room[a].players.length;i++)if(room[a].players[i]==b)c=i;
            (room[a].players[c]=room[a].players[room[a].players.length-1]);
            room[a].players.pop();
        }
    }}
    function DEAL(uint a)external{unchecked{
        require(msg.sender==room[a].players[0]); //Host only
        (uint[52]memory table,uint hash,uint c,uint bs,address[]memory rp)=(
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,
        28,31,41,12,42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,room[a].betSize,room[a].players);
        uint rl=rp.length;
        Player storage pi;uint i;uint j;uint ran;uint rb;uint highest;

        for(i=0;i<rl;i++){ //Number of active players in the room
            IWAG(iwag).BURN(rp[i],bs);
            (pi=player[rp[i]],rb+=bs); //Generate pool amount
            uint t;
            (ran=hash%c,pi.card=table[ran],table[ran]=table[c],hash/=c,c--);
            //if(j>3)(t%=10,t=t==0?10:t,pi.points=t,highest=t>=highest?t:highest);
            
        }
        c=0;
        for(i=0;i<rl;i++)if(player[rp[i]].points==highest)c++; //Getting number of winners
        c=rb*9/10/c; //5% each for host and admin 
        IWAG(iwag).MINT(rp[0],rb*1/20);
        for(i=0;i<rl;i++){ //Distribute tokens
            if(player[rp[i]].points==highest)IWAG(iwag).MINT(rp[i],c);
            if(IWAG(iwag).balanceOf(rp[i])<bs)LEAVE(a,rp[i]);
        }
    }}
    function getRoomInfo(uint a)external view returns(address[]memory b,uint[]memory c){unchecked{
        (b=room[a].players,c=new uint[](b.length));
        for(uint i=0;i<b.length;i++)c[i]=player[b[i]].card;
    }}
    function cV(uint a)private pure returns(uint){unchecked{
        a%=13;
        if(a>9)a=0;
        return a;
    }}
    function getCardRank()public view returns(uint){

    }
}