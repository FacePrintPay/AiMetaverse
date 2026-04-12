import http.server
import socketserver
import json
from urllib.parse import parse_qs, urlparse

# Store users in memory (in a real application, this would be a database)
users = {}

class AuthHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Serve static files
        if self.path == '/':
            self.path = '/login.html'
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        
        try:
            data = json.loads(post_data.decode('utf-8'))
            
            if self.path == '/api/register':
                # Handle registration
                if data.get('email') in users:
                    self._send_response({'error': 'User already exists'}, 400)
                else:
                    users[data['email']] = {
                        'name': data.get('name'),
                        'password': data.get('password')  # In real app, hash the password
                    }
                    self._send_response({'message': 'Registration successful'})
                    
            elif self.path == '/api/login':
                # Handle login
                user = users.get(data.get('email'))
                if user and user['password'] == data.get('password'):
                    self._send_response({'message': 'Login successful'})
                else:
                    self._send_response({'error': 'Invalid credentials'}, 401)
                    
            else:
                self._send_response({'error': 'Invalid endpoint'}, 404)
                
        except json.JSONDecodeError:
            self._send_response({'error': 'Invalid JSON'}, 400)
            
    def _send_response(self, data, status=200):
        self.send_response(status)
        self.send_header('Content-type', 'application/json')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(json.dumps(data).encode('utf-8'))

# Start the server
PORT = 8000
with socketserver.TCPServer(("", PORT), AuthHandler) as httpd:
    print(f"Server running at http://localhost:{PORT}")
    httpd.serve_forever()
