nasa-apod-background.deb: $(wildcard src/**/*)
	dpkg-deb --root-owner-group --build ./src nasa-apod-background.deb

clean:
	rm -f nasa-apod-background.deb
.PHONY: clean

configure: 
	
.PHONY: configure

install: nasa-apod-background.deb
	apt-get install --reinstall ./nasa-apod-background.deb
.PHONY: install
