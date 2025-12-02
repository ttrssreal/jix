{ pkgs, ... }:
{
  systemd.services.availability-listener = {
    description = "Availability healthcheck endpoint";

    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.ExecStart = pkgs.writers.writePython3 "availability-listener" { } ''
      from http.server import HTTPServer, BaseHTTPRequestHandler
      from http import HTTPStatus

      HTTP_RESPONSE_CONTENT = b"meow :3"


      class Handler(BaseHTTPRequestHandler):
          def do_GET(self):
              self.send_response(HTTPStatus.OK)
              self.send_header("Content-Length", str(len(HTTP_RESPONSE_CONTENT)))
              self.end_headers()
              self.wfile.write(HTTP_RESPONSE_CONTENT)


      def main():
          httpd = HTTPServer(("0.0.0.0", 8000), Handler)
          print("Starting http server 0.0.0.0:8000")
          httpd.serve_forever()


      if __name__ == "__main__":
          main()
    '';
  };
}
