/* DEPLOYMENT: JOIN to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/wag_backend/blob/main/more/CasinoStandard.sol";
contract LargestCard is CS{
    struct Player{
        uint[5]cards;
        uint points;
        uint room;
        uint balance;
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
        if(room[a].players.length<1){ //Initiate the room
            require(b>9); //Bet size must be more than 0
            room[a].betSize=b; //Set the room bet size
        }
        require(player[msg.sender].balance>=room[a].betSize); //Have money to bet
        require(room[a].players.length<5); //Not full
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
            (pi=player[rp[i]],pi.balance-=bs,rb+=bs); //Generate pool amount
            uint t;
            for(j=0;j<5;j++){ //Distribute 5 random & calculate highest
                (ran=hash%c,pi.cards[j]=table[ran],table[ran]=table[c],hash/=c,c--,t+=cV(pi.cards[j]));
                if(j>3)(t%=10,t=t==0?10:t,pi.points=t,highest=t>=highest?t:highest);
            }
        }
        c=0;
        for(i=0;i<rl;i++)if(player[rp[i]].points==highest)c++; //Getting number of winners
        (player[rp[0]].balance+=(rb*1/20),c=rb*9/10/c); //5% each for host and admin 
        for(i=0;i<rl;i++){ //Distribute tokens
            pi=player[rp[i]];
            if(pi.points==highest)pi.balance+=c;
            if(pi.balance<bs)LEAVE(a,rp[i]);
        }
    }}
    function getRoomInfo(uint a)external view returns(address[]memory b,uint[25]memory c){unchecked{
        b=room[a].players; //Only get cards if there is a player
        uint i;uint j;uint k;
        for(i=0;i<b.length;i++)for(j=0;j<5;j++)(c[k]=player[b[i]].cards[j],k++);
    }}
    function cV(uint a)private pure returns(uint){unchecked{
        a%=13;
        if(a>9)a=0;
        return a;
    }}
}