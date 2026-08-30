.PHONY: deploy

deploy:
	hugo
	rsync -avz --delete public/ ubuntu@10.0.57.58:/srv/gemini/plock.net/
	rm -rf public resources
