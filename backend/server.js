const express = require("express");
const bodyParser = require("body-parser");
const db = require("./database/database"); // Adjust the path to point to the database folder

const app = express();
const port = 3000;

// Middleware to parse JSON request bodies
app.use(bodyParser.json());

// API routes

// Fetch all activities
app.get("/activities", (req, res) => {
  db.all("SELECT * FROM activities", [], (err, rows) => {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ activities: rows }); // Send the list of activities in JSON format
  });
});

// Add a new activity
app.post("/activities", (req, res) => {
  const { name, description, mood } = req.body; // Destructure request body
  const query = `INSERT INTO activities (name, description, mood) VALUES (?, ?, ?)`;

  db.run(query, [name, description, mood], function (err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ id: this.lastID }); // Send back the ID of the newly inserted row
  });
});

// Update an existing activity
app.put("/activities/:id", (req, res) => {
  const { id } = req.params; // Get the activity ID from the URL
  const { name, description, mood } = req.body; // Destructure request body
  const query = `UPDATE activities SET name = ?, description = ?, mood = ? WHERE id = ?`;

  db.run(query, [name, description, mood, id], function (err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ changes: this.changes }); // Send the number of rows updated
  });
});

// Delete an activity
app.delete("/activities/:id", (req, res) => {
  const { id } = req.params; // Get the activity ID from the URL
  const query = `DELETE FROM activities WHERE id = ?`;

  db.run(query, [id], function (err) {
    if (err) {
      res.status(500).json({ error: err.message });
      return;
    }
    res.json({ changes: this.changes }); // Send the number of rows deleted
  });
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
