# run flask on dev machine
export dev="yes"; \
export FLASK_APP=lms.py; \
export zone="a/a/a/us-west1-a"; \
export hostname="bozo-1.a.a.a"; \
export PROJECT_ID=$DEVSHELL_PROJECT_ID; \
flask run --host=127.0.0.1:8080