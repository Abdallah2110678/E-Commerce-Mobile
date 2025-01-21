const express = require("express");
const bodyParser = require("body-parser");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
app.use(bodyParser.json());

// Default HTTP GET route
app.get("/", (req, res) => {
  res.send("Socket.IO server is running. Use a client to connect!");
});

const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*", // Allow connections from your Flutter app
    methods: ["GET", "POST"],
  },
});

// Store connected users
const connectedUsers = {};

io.on("connection", (socket) => {
  console.log("New client connected:", socket.id);

  // Listen for user joining with email
  socket.on("join", ({ email }) => {
    if (connectedUsers[email]) {
      console.log(`${email} is already connected.`);
      return;
    }
    connectedUsers[email] = socket.id;
    console.log(`${email} joined with socket ID ${socket.id}`);
    console.log("Connected Users:", connectedUsers); // Log the connectedUsers object
  });

  // Listen for chat messages
  socket.on("send_message", ({ sender, receiver, message }) => {
    console.log("Received message:", { sender, receiver, message });
    const receiverSocketId = connectedUsers[receiver];
    if (receiverSocketId) {
      io.to(receiverSocketId).emit("receive_message", { sender, message });
      console.log(`Message sent to ${receiver} (Socket ID: ${receiverSocketId})`);
    } else {
      console.log(`Receiver ${receiver} not found.`);
    }
  });

  // Handle disconnection
  socket.on("disconnect", () => {
    console.log("Client disconnected:", socket.id);
    for (const email in connectedUsers) {
      if (connectedUsers[email] === socket.id) {
        delete connectedUsers[email];
        break;
      }
    }
  });
});

const PORT = 4000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));