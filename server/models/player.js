const mongoose = require('mongoose');

const playerSchema = new mongoose.Schema({
    name: {
        type : String,
    },
    socketID: {
        type: String,
    },
    isPartyLeader: {
        type: String,
        default: false,
    },
    score: {
        type: Number,
        default: 0
    }
})


const playermodel = mongoose.model('Player', playerSchema);
module.exports = {playermodel,playerSchema};