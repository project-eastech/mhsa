import stomp

# ActiveMQ connection details
BROKER_HOST = 'localhost'  # Replace with your ActiveMQ server hostname or IP
BROKER_PORT = 61613        # Default port for STOMP protocol
USERNAME = 'admin'         # Replace with your ActiveMQ username
PASSWORD = 'admin'         # Replace with your ActiveMQ password

# Destination queue
QUEUE_NAME = '/queue/test'  # Replace with your queue name

# Message to send
MESSAGE = 'Hello, ActiveMQ!'

# Listener for connection events (optional)
class MyListener(stomp.ConnectionListener):
    def on_error(self, headers, message):
        print(f'Error: {message}')
    
    def on_connected(self, headers, body):
        print('Connected to ActiveMQ!')
    
    def on_disconnected(self):
        print('Disconnected from ActiveMQ!')

# Connect to the broker and send a message
def send_message():
    # Create a connection
    conn = stomp.Connection([(BROKER_HOST, BROKER_PORT)])
    conn.set_listener('', MyListener())  # Add a listener for connection events (optional)
    
    # Connect to the ActiveMQ broker
    conn.connect(USERNAME, PASSWORD, wait=True)
    
    print(f'Sending message: {MESSAGE}')
    # Send the message to the specified queue
    conn.send(body=MESSAGE, destination=QUEUE_NAME)
    
    # Disconnect after sending the message
    conn.disconnect()
    print('Message sent and connection closed.')

if __name__ == '__main__':
    send_message()
