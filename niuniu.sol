/* DEPLOYMENT: JOIN to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IWAC{
    function BURN(address,uint)external;
    function MINT(address,uint)external;
} 
contract niuniu{
    struct Player{
        uint[5]cards;
        uint[5]cardValue;
        uint[3]niu;
        uint points;
        uint room;
        uint balance;
    }
    struct Room{
        address[]players; //First player automatically is host
        uint betSize;
    }
    address private iwac;
    address private _owner;
    mapping(uint=>Room)public room;
    mapping(address=>Player)public player;
    uint[5][]private cb;
    constructor(address a){unchecked{
        (iwac,_owner)=(a,msg.sender);
        cb.push([1,2,3,4,5]);
        cb.push([1,2,4,3,5]);
        cb.push([1,2,5,3,4]);
        cb.push([1,3,4,2,5]);
        cb.push([1,3,5,2,4]);
        cb.push([1,4,5,3,4]);
        cb.push([2,3,4,1,5]);
        cb.push([2,3,5,1,4]);
        cb.push([3,4,5,1,2]);
        /* TESTING */
        player[msg.sender].balance=
        player[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2].balance=
        player[0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db].balance=
        player[0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB].balance=
        player[0x617F2E2fD72FD9D5503197092aC168c91465E7f2].balance=100;
        JOIN(1,10);
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
    function DEAL(uint a)public{unchecked{
        require(msg.sender==room[a].players[0]); //Host only
        (uint[52]memory table,uint hash,uint c,uint bs,address[]memory rp)=(
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,28,31,41,12,
        42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,room[a].betSize,room[a].players);
        uint ran;
        uint rb; //Pool amount
        for(uint i=0;i<rp.length;i++){ //Generate cards
            Player storage pi=player[rp[i]];
            (pi.balance-=bs,rb+=bs);
            for(uint j=0;j<5;j++)(ran=hash%c,pi.cards[j]=table[ran],pi.cardValue[j]=cV(table[ran]),
            table[ran]=table[c],hash/=c,c--);
        }
        delete ran;
        delete hash;
        delete table;
        for(uint i=0;i<rp.length;i++){ //Get Niu
            delete player[rp[i]].points;
            delete player[rp[i]].niu;
            uint[5]memory pc=player[rp[i]].cardValue;
            c=0;
            for(uint j=0;j<9;j++){
                //c=(pc[cb[j][0]]+pc[cb[j][1]]+pc[cb[j][2]])%10;
                if(c==0){
                    //c=(pc[cb[j][3]]+pc[cb[j][4]])%10;
                    player[rp[i]].points=c==0?10:c;
                    player[rp[i]].niu[0]=cb[j][0];
                    player[rp[i]].niu[1]=cb[j][1];
                    player[rp[i]].niu[2]=cb[j][2];
                    break;
                }
            }
            if(c>ran)(ran=c,hash=1);else if(c==ran)hash++; //Number of winners
        }/*
        (player[rp[0]].balance+=(rb*1/20),hash=rb*9/10/hash); //5% each for host and admin 
        for(uint i=0;i<rp.length;i++){ //Distribute tokens
            Player storage pi=player[rp[i]];
            if(pi.points==ran)pi.balance+=hash;
            if(pi.balance<bs)LEAVE(a,rp[i]);
        }*/
    }}
    function cV(uint a)private pure returns(uint){unchecked{
        a%=13;
        return a>9?0:a;
    }}
    function getRoomInfo(uint a)external view returns(address[]memory b,uint[]memory c,uint[]memory d){unchecked{
        (b=room[a].players,c=new uint[](b.length*5),d=new uint[](b.length*3));
        uint i;uint j;uint k;uint l;uint m;
        for(i=0;i<b.length;i++){
            for(j=0;j<5;j++)(c[k]=player[b[i]].cardValue[j],k++);
            for(l=0;l<3;l++)(d[m]=player[b[i]].niu[l],m++);
        }
    }}
}