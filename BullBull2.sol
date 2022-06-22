/* DEPLOYMENT: JOIN to external */
pragma solidity>0.8.0;//SPDX-License-Identifier:None
import"more/CasinoStandard.sol";
contract BullBull is CS{
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
    mapping(address=>mapping(uint=>Room))public room;
    mapping(address=>mapping(address=>Player))public player;
    uint[5][9]private cb;
    constructor()CS(){unchecked{
        (cb[0]=[0,1,2,3,4],cb[1]=[0,1,3,4,3],cb[2]=[0,1,4,2,3],cb[3]=[0,2,3,1,4],
        cb[4]=[0,2,4,1,3],cb[5]=[0,3,4,1,2],cb[6]=[1,2,3,0,4],cb[7]=[1,3,4,2,4],cb[8]=[2,3,4,0,1]);
    }}
    function JOIN(address _a,uint a,uint b)external{unchecked{
        (Room storage r,Player storage p)=(room[_a][a],player[_a][msg.sender]);
        if(r.players.length<1){ //Set room bet size
            require(b>9);
            r.betSize=b*1e18;
        }
        require(I20(_a).balanceOf(msg.sender)>=r.betSize); //Have money to bet
        require(r.players.length<5); //Not full
        require(p.room!=a); //Not same room
        require(a>0); //Not reserved room
        r.players.push(msg.sender); //Add a player
        p.room=a;
    }}
    function LEAVE(address _a,uint a,address b)public{unchecked{ //Only host can kick
        (Player storage p,Room storage r)=(player[_a][b],room[_a][a]);
        require(player[_a][msg.sender].room==a||msg.sender==room[_a][p.room].players[0]);
        p.room=0;
        if(r.players.length==1)delete room[_a][a]; //Delete room if no more player
        else{
            uint c; //Move players up
            for(uint i=0;i<r.players.length;i++)if(r.players[i]==b)c=i;
            (r.players[c]=r.players[r.players.length-1]);
            r.players.pop();
        }
    }}
    function DEAL(address _a,uint a)external{unchecked{
        Room memory r=room[_a][a];
        require(msg.sender==r.players[0]); //Host only
        (uint[52]memory table,uint hash,uint c,uint bs,address[]memory rp)=(
        [uint(3),39,19,36,6,24,46,16,29,34,47,1,7,13,15,44,25,18,37,21,28,31,41,12,
        42,14,4,32,23,9,17,51,2,5,43,33,20,40,8,49,52,30,22,27,38,35,45,50,26,48,10,11],
        uint(keccak256(abi.encodePacked(block.timestamp))),51,r.betSize,r.players);
        uint ran;
        uint rb; //Pool amount
        for(uint i=0;i<rp.length;i++){ //Generate cards
            Player storage pi=player[_a][rp[i]];
            I20(_a).BURN(rp[i],bs);
            rb+=bs;
            uint temp;
            for(uint j=0;j<5;j++)(ran=hash%c,pi.cards[j]=table[ran],temp=table[ran]%13,
            pi.cardValue[j]=temp>9?0:temp,table[ran]=table[c],hash/=c,c--);
        }
        delete table;
        delete ran;
        delete hash;
        for(uint i=0;i<rp.length;i++){ //Get Niu
            delete player[_a][rp[i]].points;
            delete player[_a][rp[i]].niu;
            Player storage p=player[_a][rp[i]];
            uint[5]memory pc=p.cardValue;
            for(uint j=0;j<9;j++){
                c=(pc[cb[j][0]]+pc[cb[j][1]]+pc[cb[j][2]])%10;
                if(c==0){
                    (c=(pc[cb[j][3]]+pc[cb[j][4]])%10,p.points=c==0?10:c,p.niu[0]=cb[j][0],
                    p.niu[1]=cb[j][1],p.niu[2]=cb[j][2]);
                    break;
                }
                delete c;
            }
            if(c>ran)(ran=c,hash=1);else if(c==ran)hash++; //Number of winners
        }
        I20(_a).MINT(rp[0],rb*1/20);
        hash=rb*9/10/hash; //5% each for host and admin 
        for(uint i=0;i<rp.length;i++){ //Distribute tokens
            if(player[_a][rp[i]].points==ran)I20(_a).MINT(rp[i],hash);
            if(I20(_a).balanceOf(rp[i])<bs)LEAVE(_a,a,rp[i]);
        }
    }}
    function getRoomInfo(address _a,uint a)external view returns(address[]memory b,uint[]memory c,
    uint[]memory d,uint[]memory e,uint f){unchecked{
        Room memory r=room[_a][a];
        (b=r.players,c=new uint[](b.length*5),d=new uint[](b.length*3),e=new uint[](b.length));
        uint i;uint j;uint k;uint l;uint m;
        for(i=0;i<b.length;i++){
            Player memory p=player[_a][b[i]];
            for(j=0;j<5;j++)(c[k]=p.cards[j],k++);
            for(l=0;l<3;l++)(d[m]=p.niu[l],m++);
            e[i]=p.points;
        }
        f=r.betSize;
    }}
}