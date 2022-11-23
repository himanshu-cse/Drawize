const express = require("express");
var http = require("http");
const app =express();
const port = process.env.PORT || 3000;
var server = http.createServer(app);
const mongoose = require("mongoose");
const Room = require("./models/room.js");
var io = require("socket.io")(server);
const getword = require('./api/words')
// import MongoClient from 'mongodb';


// converting data into json

app.use(express.json());

//connect to database mongoose

const DB = 'mongodb://0.0.0.0:27017/drawize';

mongoose.connect(DB, {useUnifiedTopology: true}).then(() => {
    console.log('succesful!');
}).catch(e =>{
    console.log(e);
})


io.on('connection',(socket) =>{
    console.log('connected');



    //create game callback
    socket.on('create-game',async({nickname, name, occupancy, maxRounds}) =>{
        try{
            const isRoomNotNew = await Room.findOne({name});
            if (isRoomNotNew){
                socket.emit('roomalreadyexist', 'Room with that ID already exists!');
                return;
            }
            let room = new Room();
            const word = getword();
            room.word = word;
            room.name = name;
            room.occupancy = occupancy;
            room.maxRounds = maxRounds;

            let player = {
                socketID: socket.id,
                nickname,
                isPartyLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(name);
            io.to(nickname).emit('updateRoom',room);


        }catch(err){
            console.log(err);
        }
    })



    //join room callback
    socket.on('join-game',async({nickname,name})=>{
        // console.log(nickname);
        try{
            let room = await Room.findOne({name});
            // console.log(room);
            if(!room){
                console.log('error');
                socket.emit('notCorrectGame', 'Please Enter a valid room name');
                return;
            }
            if(room.isJoin){
                let player = {
                    socketID: socket.id,
                    nickname,
                    isPartyLeader:false,
                }
                // console.log(player);
                room.players.push(player);
                socket.join(name);
                if (room.players.length == room.occupancy) {
                    room.isJoin = false;                    
                }
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                io.to(nickname).emit('updateRoom',room);
            }
            else{
                socket.emit('notCorrectGame', 'Room is full, please try again later!');
                return;   
            }


        }catch(err){
            console.log(err);
        }
    })


});


server.listen(port, '0.0.0.0', () => {
    console.log('server started and running at port :' + port);
})
// 
