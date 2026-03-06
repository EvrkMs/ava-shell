#!/usr/bin/env python3
import os
import socket
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer

role = os.environ.get("ROLE", "replica")


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/primary" and role == "primary":
            self.send_response(200)
        else:
            self.send_response(503)
        self.end_headers()

    def log_message(self, fmt, *args):
        return


def run_http():
    HTTPServer(("0.0.0.0", 8008), Handler).serve_forever()


def run_tcp():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    sock.bind(("0.0.0.0", 5432))
    sock.listen(128)
    while True:
        conn, _ = sock.accept()
        conn.sendall((role + "\n").encode("utf-8"))
        conn.close()


threading.Thread(target=run_http, daemon=True).start()
run_tcp()
