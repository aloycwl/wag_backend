/* DEPLOYMENT: JOIN to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"https://github.com/aloycwl/wag_backend/blob/main/more/CasinoStandard.sol";
contract niuniu is CS{
    struct Player{
        uint[5]cards;
        uint[5]cardValue;
        uint[3]niu;
        uint points;
        uint room;
    }
    struct Room{
        address[]players; //First player automatically is host
        uint betSize;
    }
    address private iwag;
    address private _owner;
    mapping(uint=>Room)public room;
    mapping(address=>Player)public player;
    uint[5][9]private cb;
    constructor(address a){unchecked{
        (iwag=a,_owner=msg.sender,cb[0]=[0,1,2,3,4],cb[1]=[0,1,3,4,3],cb[2]=[0,1,4,2,3],cb[3]=[0,2,3,1,4],
        cb[4]=[0,2,4,1,3],cb[5]=[0,3,4,1,2],cb[6]=[1,2,3,0,4],cb[7]=[1,3,4,2,4],cb[8]=[2,3,4,0,1]);
    }}
    function JOIN(uint a,uint b)external{unchecked{
        if(room[a].players.length<1){ //Set room bet size
            require(b>9);
            room[a].betSize=b*1e18;
        }
        require(IWAG(iwag).balanceOf(msg.sender)>=room[a].betSize); //Have money to bet
        require(room[a].players.length<5); //Not full
        require(player[msg.sender].room!=a); //Not same room
        require(a>0); //Not reserved room
        room[a].players.push(msg.sender); //Add a player
        player[msg.sender].room=a;
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
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,28,31,41,12,
        42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,room[a].betSize,room[a].players);
        uint ran;
        uint rb; //Pool amount
        for(uint i=0;i<rp.length;i++){ //Generate cards
            Player storage pi=player[rp[i]];
            IWAG(iwag).BURN(rp[i],bs);
            rb+=bs;
            uint temp;
            for(uint j=0;j<5;j++)(ran=hash%c,pi.cards[j]=table[ran],temp=table[ran]%13,
            pi.cardValue[j]=temp>9?0:temp,table[ran]=table[c],hash/=c,c--);
        }
        delete table;
        delete ran;
        delete hash;
        for(uint i=0;i<rp.length;i++){ //Get Niu
            delete player[rp[i]].points;
            delete player[rp[i]].niu;
            uint[5]memory pc=player[rp[i]].cardValue;
            for(uint j=0;j<9;j++){
                c=(pc[cb[j][0]]+pc[cb[j][1]]+pc[cb[j][2]])%10;
                if(c==0){
                    (c=(pc[cb[j][3]]+pc[cb[j][4]])%10,player[rp[i]].points=c==0?10:c,player[rp[i]].niu[0]=cb[j][0],
                    player[rp[i]].niu[1]=cb[j][1],player[rp[i]].niu[2]=cb[j][2]);
                    break;
                }
                delete c;
            }
            if(c>ran)(ran=c,hash=1);else if(c==ran)hash++; //Number of winners
        }
        IWAG(iwag).MINT(rp[0],rb*1/20);
        hash=rb*9/10/hash; //5% each for host and admin 
        for(uint i=0;i<rp.length;i++){ //Distribute tokens
            if(player[rp[i]].points==ran)IWAG(iwag).MINT(rp[i],hash);
            if(IWAG(iwag).balanceOf(rp[i])<bs)LEAVE(a,rp[i]);
        }
    }}
    function getRoomInfo(uint a)external view returns(address[]memory b,uint[]memory c,uint[]memory d){unchecked{
        (b=room[a].players,c=new uint[](b.length*5),d=new uint[](b.length*3));
        uint i;uint j;uint k;uint l;uint m;
        for(i=0;i<b.length;i++){
            for(j=0;j<5;j++)(c[k]=player[b[i]].cards[j],k++);
            for(l=0;l<3;l++)(d[m]=player[b[i]].niu[l],m++);
        }
    }}
}