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

from google.cloud import pubsub_v1
from google.cloud import storage

import os
import config

# open a log file for writing
log = open('/ce-demo-lms/vtc_log.txt','w')


def logger(entry):
    log.write(entry + '\n')
    log.flush()


def sub():
    dir_path = "{}/tmp".format(os.path.dirname(os.path.realpath(__file__)))

    gcs_client = storage.Client(project=config.PROJECT_ID)
    in_bucket = gcs_client.get_bucket(config.SOURCE_STORAGE_BUCKET)
    out_bucket = gcs_client.get_bucket(config.TARGET_STORAGE_BUCKET)

    subscriber_client = pubsub_v1.SubscriberClient()
    subscription_path = subscriber_client.subscription_path(config.PROJECT_ID, "videos")

    def callback(message):
        object_name=message.data.decode('utf-8')

        # read the file from gcs
        source_blob = in_bucket.blob('videos/{}'.format(object_name))
        in_file_name = '{}/in/{}'.format(dir_path,object_name)
        with open(in_file_name, 'wb') as file_obj:
            source_blob.download_to_file(file_obj)

        # do the transcoding
        for size in ['480','720','1080']:
            out_object_name = "{}_{}".format(size,object_name)
            out_file_name = "{}/out/{}".format(dir_path,out_object_name)
            ret = os.system('ffmpeg -y -i {} -vf scale=-"trunc(oh*2/2)*2:{}" {}'.format(in_file_name,size,out_file_name))
            logger(out_file_name)
            logger(str(ret))

            # write back into target bucket and remove from local disk
            target_blob = out_bucket.blob(out_object_name)
            target_blob.upload_from_filename(out_file_name)
            os.system('rm {}'.format(out_file_name))

        # remove the source file
        os.system('rm {}'.format(in_file_name))
        logger("processing {}\n".format(message.attributes['uri']))
        print(f"Acknowledged {message.message_id}.")
        message.ack()

    streaming_pull_future = subscriber_client.subscribe(subscription_path, callback)
    print(f"Listening for messages on {subscription_path}..\n")

    try:
        streaming_pull_future.result()
        print("waiting")
    except:
        streaming_pull_future.cancel()

    subscriber_client.close()

if __name__ == "__main__":
    sub()