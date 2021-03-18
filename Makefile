.PHONY: deploy

deploy:
	hugo
	scp -r public/* root@10.0.57.44:/srv/gemini/plock.net/
	rm -rf public resources
