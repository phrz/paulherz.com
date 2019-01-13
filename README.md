## Local setup:
1. `brew cask install docker`
2. Start Docker.app (ensure it's running if you get daemon connection errors)
3. `git clone git@github.com:phrz/paulherz.com`
4. `cd paulherz.com`

## Local site testing:
4. `make serve`
5. `open http://localhost:4000/`

## Server setup (assumes `root` user):
1. Spin up a Ubuntu VM and attach to IP for paulherz.com. Setup ssh certs. Setup `ph` alias on local dev machine.
2. `curl https://getcaddy.com | bash -s personal`
3. `apt install git`
4. `git clone https://github.com/phrz/paulherz.com.git`
5. `cd paulherz.com`
6. `cp Caddyfile ..`
7. `cp keepup.sh ..`
8. `cd ..`
9. `chmod +x keepup.sh`
10. `mkdir -p /var/www/paulherz`
11. Edit `Caddyfile` to contain email address.
12. Run `crontab -e` and add `*/10 * * * * /root/keepup.sh` (every 10 min)

## Push the site:
1. `make` (builds from scratch and deploys to `/var/www/paulherz` folder)

Note: you may occassionally need to update the jekyll Docker image, do so with `docker pull jekyll/jekyll` on your development machine.
