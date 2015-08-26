#!/usr/bin/env python
"""
A simple HTTP server designed to receive posts that contain test summary information
to be written into the Victorious iOS Wiki.  Automation tests will send POSTs to this
server.
"""

from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import urlparse

file_path = ""

class PostTestStepServer(BaseHTTPRequestHandler):
    def _set_headers(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

    def do_POST(self):
        length = int(self.headers['Content-Length'])
        post_data = urlparse.parse_qs(self.rfile.read(length).decode('utf-8'))
        mode = "a" if post_data["append"][0] == 'true' else "w"
        text = post_data["text"][0]
        f = open(file_path, mode)
        f.write('\n' + text)
        f.close()


def run(server_class=HTTPServer, handler_class=PostTestStepServer, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print 'Starting httpd...'
    httpd.serve_forever()

if __name__ == "__main__":
    from sys import argv

    file_path = str(argv[2])
    run(port=int(argv[1]))
