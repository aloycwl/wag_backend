pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"more/CasinoStandard.sol";
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
    mapping(address=>mapping(uint=>Room))public room;
    mapping(address=>mapping(address=>Player))public player;
    constructor()CS(){}
    function JOIN(address _a,uint a,uint b)public{unchecked{
        (Room storage r,Player storage p)=(room[_a][a],player[_a][msg.sender]);
        if(r.players.length<1){
            require(b>9);
            r.betSize=b*1e18;
        }
        require(I20(_a).balanceOf(msg.sender)>=r.betSize); //Have money to bet
        require(r.players.length<20); //Not full
        require(p.room!=a); //Not same room
        require(a>0); //Not reserved room
        I20(_a).transferFrom(msg.sender,address(this),r.betSize);
        r.players.push(msg.sender); //Add a player
        p.room=a; //In case player disconnect
    }}
    function LEAVE(address _a,uint a,address b)public{unchecked{ //Only host can kick
        require(player[_a][msg.sender].room==a||msg.sender==room[_a][player[_a][b].room].players[0]);
        player[_a][b].room=0;
        Room storage r=room[_a][a];
        if(r.players.length==1)delete room[_a][a]; //Delete room if no more player
        else{
            uint c; //Move players up
            for(uint i=0;i<r.players.length;i++)if(r.players[i]==b)c=i;
            (r.players[c]=r.players[r.players.length-1]);
            r.players.pop();
        }
    }}
    function DEAL(address _a,uint a)external{unchecked{
        require(msg.sender==room[_a][a].players[0]); //Host only
        (uint[52]memory table,uint hash,uint c,uint bs,address[]memory rp)=(
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,
        28,31,41,12,42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,room[_a][a].betSize,room[_a][a].players);
        uint rl=rp.length;
        uint ran;uint rb;uint highest;
        for(uint i=0;i<rl;i++){ //Number of active players in the room
            Player storage p=player[_a][rp[i]];
            (rb+=bs,ran=hash%c,p.card=table[ran],table[ran]=table[c],hash/=c,c--);
            uint cardVal=p.card%13;
            if(cardVal==0)cardVal=13;
            uint mul=4-((p.card-cardVal)/13);
            (mul=cardVal*4-(4-mul),p.points=cardVal==1?mul+52:mul);
            if(p.points>highest)highest=p.points;
        }
        I20(_a).transferFrom(address(this),rp[0],rb/20); //5% each for host and admin, only 1 winner
        cashout(_a,rb/20);
        for(uint i=0;i<rl;i++){
            if(player[_a][rp[i]].points==highest)I20(_a).transferFrom(address(this),rp[i],rb*9/10);
            if(I20(_a).balanceOf(rp[i])<bs)LEAVE(_a,a,rp[i]);
        }
    }}
    function getRoomInfo(address _a,uint a)external view returns(address[]memory b,uint[]memory c,uint[]memory d,uint e){
    unchecked{
        (b=room[_a][a].players,c=new uint[](b.length),d=new uint[](b.length));
        for(uint i=0;i<b.length;i++)(c[i],d[i])=(player[_a][b[i]].card,player[_a][b[i]].points);
        e=room[_a][a].betSize;
    }}
}