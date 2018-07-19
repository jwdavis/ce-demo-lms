"""
Copyright SuccessOps, LLC 2017
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

from google.cloud import pubsub
from google.cloud import storage

import os
import config

# open a log file for writing
log = open('/ce-demo-lms/vtc_log.txt','w')

# set working directory for transcoding
dir_path = "{}/tmp".format(os.path.dirname(os.path.realpath(__file__)))

# create pubsub client and get topic/subscription
ps_client = pubsub.Client()
topic = ps_client.topic("video_to_transcode")
sub = topic.subscription('file_ready')

# create storage client
gcs_client = storage.Client(project=config.PROJECT_ID)
in_bucket = gcs_client.get_bucket(config.SOURCE_STORAGE_BUCKET)
out_bucket = gcs_client.get_bucket(config.TARGET_STORAGE_BUCKET)

def logger(entry):
    log.write(entry + '\n')
    log.flush()
    print entry

# loop forever
while True:
    logger('polling')
    message = None

    # pull the next message
    pulled = sub.pull(return_immediately=False,max_messages=1)
    for ack_id, message in pulled:
        sub.acknowledge([ack_id])
        logger("processing {}\n".format(message.attributes['uri']))

    # check to see if the pull returned a message
    if message:
        try:
            # grab the uri
            object_name=message.attributes['uri']
            if object_name != 'q_stuffing':

                # read the file from gcs
                source_blob = in_bucket.blob('videos/{}'.format(object_name))
                in_file_name = '{}/in/{}'.format(dir_path,object_name)
                with open(in_file_name, 'wb') as file_obj:
                    source_blob.download_to_file(file_obj)

                # do the transcoding
                for size in ['480','720','1080']:
                    out_object_name = "{}_{}".format(size,object_name)
                    out_file_name = "{}/out/{}".format(dir_path,out_object_name)
                    ret = os.system('avconv -i {} -strict experimental -y -s hd{} {}'.format(in_file_name,size,out_file_name))
                    logger(out_file_name)
                    logger(str(ret))

                    # write back into target bucket and remove from local disk
                    target_blob = out_bucket.blob(out_object_name)
                    target_blob.upload_from_file(open(out_file_name))
                    os.system('rm {}'.format(out_file_name))

                # remove the source file
                os.system('rm {}'.format(in_file_name))
            else:
                logger('stuffer message for flushing queue')
        except:
            logger('something went wrong')

    # pull failed to return message
    else:
        logger("timeout...")
