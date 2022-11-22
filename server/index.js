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
    socket.on('create_game',async({name, roomID, numPlayers, numRounds}) =>{
        try{
            const isRoomNotNew = await Room.findOne({roomID});
            if (isRoomNotNew){
                socket.emit('roomalreadyexist', 'Room with that ID already exists!');
                return;
            }
            let room = new Room();
            const word = getword();
            room.word = word;
            room.roomID = roomID;
            room.numPlayers = numPlayers;
            room.numRounds = numRounds;

            let player = {
                socketID: socket.id,
                name,
                isPartyLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(room);
            io.to(name).emit('updateRoom',room);


        }catch(err){
            console.log(err);
        }
    })
})



server.listen(port, '0.0.0.0', () => {
    console.log('server started and running at port :' + port);
})
// 
