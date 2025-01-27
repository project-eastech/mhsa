import stomp
import time

class MyListener(stomp.ConnectionListener):
    def on_message(self, frame):
        print(f"Message received: {frame.body}")

    def on_error(self, frame):
        print(f"Error: {frame.body}")

    def on_disconnected(self):
        print("Disconnected from broker!")

# Broker connection settings
conn = stomp.Connection([('localhost', 61613)])
listener = MyListener()
conn.set_listener('', listener)

# Connect and subscribe
conn.connect('admin', 'admin', wait=True)
conn.subscribe(destination='/queue/example', id=1, ack='auto')

# Keep the script running to listen for messages
try:
    print("Listening for messages...")
    while True:
        time.sleep(1)  # Prevent high CPU usage
except KeyboardInterrupt:
    print("Shutting down...")
finally:
    conn.disconnect()
