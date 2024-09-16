const mongoose = require("mongoose");

// Replace with your connection string
const uri =
  "mongodb+srv://kindkeido0208:jJlCewTIdisyGms8@tweenmindfulness.jyi8c.mongodb.net/?retryWrites=true&w=majority&appName=TweenMindfulness";

// Connect to MongoDB Atlas
mongoose
  .connect(uri, {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => console.log("MongoDB Atlas connected"))
  .catch((err) => console.error("Error connecting to MongoDB Atlas:", err));

const ItemSchema = new mongoose.Schema({
  name: String,
  description: String,
});

const Item = mongoose.model("Item", ItemSchema);

// Example of creating a new document
const newItem = new Item({
  name: "Test Item",
  description: "This is a test item",
});

newItem
  .save()
  .then(() => console.log("Item saved"))
  .catch((err) => console.error("Error saving item:", err));
