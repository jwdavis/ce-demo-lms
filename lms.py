# Copyright 2017 SuccessOps, LLC All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from flask import Flask
from flask import request, redirect, render_template, url_for
from flask import Response
from google.cloud import storage, pubsub_v1

import MySQLdb
import os
import config

app = Flask(__name__)
app.config['DEBUG'] = True

INSTANCE_METADATA = {"zone":config.SERVER_ZONE, "name":config.SERVER_NAME}
TOPIC = "projects/{}/topics/videos".format(config.PROJECT_ID)

publisher = pubsub_v1.PublisherClient(
    batch_settings = pubsub_v1.types.BatchSettings(max_messages=1)
)
storage_client = storage.Client()
bucket = storage_client.bucket(config.CLOUD_STORAGE_BUCKET)


def get_read_replica (region):
    if region == "us-west1":
        return 

# home page
@app.route('/')
def show_home():
    return render_template('home.html', instance_metadata=INSTANCE_METADATA)

### modules ###
# upload file to gcs
def upload_file(file):
    if not file:
        return None

    blob = bucket.blob("videos/{}".format(file.filename))
    blob.upload_from_string(
        file.read(),
        content_type=file.content_type
    )
    return blob.public_url

# module list page
@app.route('/modules')
def show_modules():
    db = MySQLdb.connect(host="127.0.0.1", user="lms-app", port=33060, passwd=config.SQL_PASSWORD)
    cur = db.cursor()
    cur.execute('SELECT id, name, description FROM lms.modules')
    rows = cur.fetchall()
    modules = []
    for row in rows:
        row_obj = {}
        row_obj['id'] = row[0]
        row_obj['name'] = row[1]
        row_obj['description'] = row[2]
        modules.append(row_obj)
    return render_template('modules.html', modules=modules, instance_metadata=INSTANCE_METADATA)

# add new module
@app.route('/module/add', methods=['GET','POST'])
def create_module():
    if request.method == 'POST':
        data = request.form.to_dict(flat=True)
        media_url = upload_file(request.files.get('module_media'))
        pieces = media_url.split('/')
        object_name = pieces[len(pieces)-1]
        publisher.publish(TOPIC, object_name.encode('utf=8'))
        db = MySQLdb.connect(host="127.0.0.1", user="lms-app", port=3306, passwd=config.SQL_PASSWORD)
        cur = db.cursor()
        cur.execute('INSERT INTO lms.modules (name, description, content, media) VALUES ("{}","{}","{}","{}")'.format(data['title'],data['description'],data['author'],object_name))
        db.commit()
        db.close()
        return redirect('/modules', code=302)
    return render_template('module_form.html', instance_metadata=INSTANCE_METADATA)

# show module page
@app.route('/module/<module_id>')
def show_module(module_id):
    db = MySQLdb.connect(host="127.0.0.1", user="lms-app", port=33060, passwd=config.SQL_PASSWORD)
    cur = db.cursor()
    cur.execute('SELECT name, description, media  FROM lms.modules WHERE id={}'.format(module_id))
    rows = cur.fetchall()
    db.close()
    module = {}
    for row in rows:
        module['name'] = row[0]
        module['description'] = row[1]
        module['media'] = row[2]
        module['row'] = row
    return render_template('module.html', module=module, instance_metadata=INSTANCE_METADATA, bucket=config.CLOUD_STORAGE_BUCKET)

### paths ###
# paths list page
@app.route('/paths')
def show_paths():
    db = MySQLdb.connect(host="127.0.0.1", user="lms-app", port=33060, passwd=config.SQL_PASSWORD)
    cur = db.cursor()
    cur.execute('SELECT id, name, description FROM lms.paths')
    rows = cur.fetchall()
    paths = []
    for row in rows:
        row_obj = {}
        row_obj['id'] = row[0]
        row_obj['name'] = row[1]
        row_obj['description'] = row[2]
        paths.append(row_obj)
    return render_template('paths.html',paths=paths, instance_metadata=INSTANCE_METADATA)

# show path page
@app.route('/path/<path_name>')
def show_path(path_name):
    return "path: {}".format(path_name)
    return render_template('path.html')

### users ###
# show user profile
@app.route('/user/<user_name>')
def show_user(user_name):
    return "user: {}".format(user_name)
    return render_template('user.html')

if __name__ == '__main__':
    app.run(debug=True)
