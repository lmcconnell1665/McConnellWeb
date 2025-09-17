clean:
	echo "deleting generated HTML"
	rm -rf public
	
setup:
	python3.11 -m venv ~/.McConnellWeb

install:
	pip install --upgrade pip &&\
		pip install -r requirements.txt