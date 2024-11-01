
const sqlite3 = require('sqlite3').verbose();
const player = require('play-sound')(); // for playing audio, may vary based on platform
const path = require('path');

class AudioManager {
    constructor() {
        this.db = new sqlite3.Database('mindfulness_audio.db', (err) => {
            if (err) console.error(err.message);
            console.log("Connected to the SQLite database.");
        });
        this.assetsPath = path.join(__dirname, 'assets');  // Path to assets folder
        this._setupDatabase();
        this.currentAudio = null;
        this.isPlaying = false;
        this.loop = false;
        this.volume = 1.0;
    }

    _setupDatabase() {
        this.db.run(`
            CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY, session_name TEXT)
        `);
        this.db.run(`
            CREATE TABLE IF NOT EXISTS cues (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER, time_sec INTEGER, message TEXT, FOREIGN KEY (session_id) REFERENCES sessions (id))
        `);
        this.db.run(`
            CREATE TABLE IF NOT EXISTS playback_progress (id INTEGER PRIMARY KEY, session_id INTEGER, last_position INTEGER, FOREIGN KEY (session_id) REFERENCES sessions (id))
        `);
    }

    initializeAudioSession(sessionId) {
        const sessionName = `Session ${sessionId}`;
        this.db.run("INSERT OR IGNORE INTO sessions (id, session_name) VALUES (?, ?)", [sessionId, sessionName]);
        console.log(`Session ${sessionId} initialized.`);
        return true;
    }

    playAudio(audioFile, loop = false) {
        const audioPath = path.join(this.assetsPath, audioFile);
        this.isPlaying = true;
        this.loop = loop;
        this.currentAudio = audioPath;
        player.play(audioPath, (err) => {
            if (err) console.error(`Could not play audio: ${err}`);
            if (!this.loop) this.isPlaying = false;
        });
        return true;
    }

    pauseAudio() {
        this.isPlaying = false;
        console.log("Audio paused.");
    }

    resumeAudio() {
        this.isPlaying = true;
        console.log("Audio resumed.");
        this.playAudio(this.currentAudio, this.loop);
    }

    stopAudio() {
        this.isPlaying = false;
        this.currentAudio = null;
        console.log("Audio stopped.");
    }

    adjustVolume(level) {
        this.volume = Math.max(0.0, Math.min(level, 1.0));
        console.log(`Volume set to ${this.volume * 100}%`);
    }

    addMindfulnessCues(sessionId, time_sec, message) {
        this.db.run("INSERT INTO cues (session_id, time_sec, message) VALUES (?, ?, ?)", [sessionId, time_sec, message]);
        console.log(`Cue added for session ${sessionId} at ${time_sec}s: ${message}`);
    }

    fetchAudioDuration(audioFile) {
        const ffmpeg = require('fluent-ffmpeg');
        const audioPath = path.join(this.assetsPath, audioFile);
        ffmpeg.ffprobe(audioPath, (err, metadata) => {
            if (err) console.error(`Error fetching duration: ${err}`);
            else console.log(`Duration: ${metadata.format.duration} seconds`);
        });
    }

    getMindfulnessCues(sessionId, callback) {
        this.db.all("SELECT time_sec, message FROM cues WHERE session_id = ?", [sessionId], (err, rows) => {
            if (err) console.error(err.message);
            callback(rows);
        });
    }
}

// Example usage:
// const manager = new MindfulnessAudioManager();
// manager.initializeAudioSession(1);
// manager.playAudio('example_audio.mp3', true);
// manager.addMindfulnessCues(1, 30, "Take a deep breath");
// manager.getMindfulnessCues(1, (cues) => {
//     console.log(cues);
// });

module.exports = AudioManager;
