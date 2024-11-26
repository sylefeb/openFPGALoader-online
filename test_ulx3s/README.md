# OpenFPGALoader online test

This test will program a blinky on a ULX3S board, using the ulx3s profile of 
openFPGALoader. The bitstream is in the accomapnying zip file.

The page is meant to be served locally using the python script `serve.py`.
First generate a `key.pem` and `cert.pem` using `openssl req -newkey rsa:2048 -new -nodes -x509 -days 3650 -keyout key.pem -out cert.pem`. Serve the page with `pythn serve.py`.

## Credits
- Uses jszip https://stuk.github.io/jszip/