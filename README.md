You need docker on your host machine. You may need to start the docker GUI if on macOS or Windows to get the daemon going.

Have `caddy` installed on the server, following official instructions. 

Put the `Caddyfile` in the user home, along with `keepup.sh`. 
Run `crontab -e` and add a Cron job for `keepup` every ten minutes:
```
*/10 * * * * /root/keepup.sh
```

For a VPS whose only user is root. You may need to run `chmod +x keepup.sh`.
Edit the `Caddyfile` to contain your email. Run `mkdir -p /var/www/paulherz` before deploying.

To setup locally, run `make setup`. To build and upload, run `make` (the build and deploy targets). On the server, this will push to `/var/www/paulherz`. This assumes you have proper certificates for paulherz.com established on your host machine.
