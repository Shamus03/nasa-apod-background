nasa-apod-background.deb: $(wildcard src/* src/**/* src/**/**/*)
	dpkg-deb --root-owner-group --build ./src nasa-apod-background.deb

clean:
	rm -f nasa-apod-background.deb
.PHONY: clean

install: nasa-apod-background.deb
	apt-get remove -y nasa-apod-background || :
	apt-get install -y ./nasa-apod-background.deb
.PHONY: install
