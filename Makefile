DOCKER_JEKYLL=docker run --rm \
--volume="$(PWD):/srv/jekyll" \
--volume="$(PWD)/vendor/bundle:/usr/local/bundle" \
--publish 4000:4000 \
-it jekyll/jekyll jekyll

default: build deploy

help:
	perl -wnE'say for/^[^\s:]+/g'<Makefile
serve:
	#bundler exec jekyll serve --drafts
	$(DOCKER_JEKYLL) serve --drafts
build:
	#bundler exec jekyll build
	$(DOCKER_JEKYLL) build
deploy:
	# --compress --one-file-system --recursive --checksum
	rsync --progress -zxrc --delete _site/ ph:/var/www/paulherz/
clean:
	#bundler exec jekyll clean
	$(DOCKER_JEKYLL) clean
