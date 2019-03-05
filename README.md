# [Bitwarden](https://hub.docker.com/r/p3lim/bitwarden/)

[Bitwarden](https://bitwarden.com/) is an open-source password manager that is possible to host on-premise.  
This image implements the [bitwarden_rs](https://github.com/dani-garcia/bitwarden_rs) server API component and vault web-interface.

### Build Info

- Image: [p3lim/alpine:3.8](https://github.com/p3lim/docker-alpine)
- Ports:
	- _8080/tcp_ (web interface)
	- _3012/tcp_ (websocket notifications)
- Volumes:
	- `/data`
- Environment:
	- `PUID` (user id)
	- `PGID` (user group)
	- `TZ` (timezone, e.g. `Europe/Paris`)

For more environment variables used for configuration, check out the [bitwarden_rs wiki page](https://github.com/dani-garcia/bitwarden_rs/wiki).

Example reverse-proxy using [Caddy](https://hub.docker.com/r/p3lim/caddy/)

```Caddyfile
example.com {
	tls

	proxy /notifications/hub/negotiate <container>:8080 {
		transparent
	}

	proxy /notifications/hub <container>:3012 {
		websocket
	}

	proxy / <container>:8080 {
		transparent
	}
}
```
