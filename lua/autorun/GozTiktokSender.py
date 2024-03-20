import asyncio
import websockets
from TikTokLive import TikTokLiveClient
from TikTokLive.types.events import CommentEvent, ConnectEvent

# Instantiate the client with the user's username
client: TikTokLiveClient = TikTokLiveClient(unique_id="@nataliarest")

# Create a set to keep track of connected Garry's Mod clients
garrys_mod_clients = set()

# Define how you want to handle specific events via decorator
@client.on("connect")
async def on_connect(_: ConnectEvent):
    print("Connected to Room ID:", client.room_id)

# Notice no decorator?
async def on_comment(event: CommentEvent):
    print(f"{event.user.nickname} -> {event.comment}")

    # Forward the comment to Garry's Mod clients
    await send_to_garrys_mod_clients(f"{event.user.unique_id} -> {event.comment}")

# Define handling an event via a "callback"
client.add_listener("comment", on_comment)

# Function to send a message to all connected Garry's Mod clients
async def send_to_garrys_mod_clients(message):
    # Iterate over all connected clients and send the message
    for client in garrys_mod_clients:
        await client.send(message)

# Function to handle WebSocket connections from Garry's Mod clients
async def websocket_handler(websocket, path):
    # Add the Garry's Mod client to the set of connected clients
    garrys_mod_clients.add(websocket)

    try:
        # Keep the connection open
        async for message in websocket:
            # Process the received message from Garry's Mod, if needed
            pass
    finally:
        # Remove the Garry's Mod client from the set of connected clients when the connection is closed
        garrys_mod_clients.remove(websocket)

if __name__ == '__main__':
    # Start the WebSocket server
    start_server = websockets.serve(websocket_handler, "127.0.0.1", 8080)  # Cambia esto con la dirección y el puerto adecuados
    asyncio.get_event_loop().run_until_complete(start_server)

    # Start the TikTokLive client
    asyncio.get_event_loop().create_task(client.start())

    # Run the event loop forever
    asyncio.get_event_loop().run_forever()
