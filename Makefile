.PHONY: deploy

deploy:
	hugo
	scp -r public/* ubuntu@10.0.57.58:/srv/gemini/plock.net/
	rm -rf public resources
