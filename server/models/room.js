const mongoose = require('mongoose');
const {playerSchema} = require('./player')
const roomSchema = new mongoose.Schema({
    word :{
        required: true,
        type: String,
    },
    roomID :{
        required: true,
        type: String,
        unique: true,
    },
    numPlayers :{
        required: true,
        type: Number,
    },
    numRounds :{
        required: true,
        type: Number,
    },
    currentRound :{
        required: true,
        type: Number,
        default: 1,
    },
    players: [playerSchema],
    isJoin:{
        type: Boolean,
        default: true,
    },
    turn: playerSchema,
    turnIndex:{
        type: Number,
        default: 0,
    }
})


const game = mongoose.model('Room',roomSchema);

module.exports = game;
