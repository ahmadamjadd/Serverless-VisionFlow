import json
import boto3
import cv2
import numpy as np
import os

s3_client = boto3.client('s3')
sns_client = boto3.client('sns')

def lambda_handler(event, context):
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    destination_bucket = 'image-resizer-destination-908' 
    
    download_path = '/tmp/{}'.format(key)
    upload_path = '/tmp/processed-{}'.format(key)
    
    print(f"Triggered by: {key} from {source_bucket}")

    try:
        s3_client.download_file(source_bucket, key, download_path)

        img = cv2.imread(download_path)
        
        if img is None:
            raise Exception("Could not read image. Is it a valid JPG?")

        gray_img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        
        height, width = gray_img.shape
        new_dim = (int(width * 0.5), int(height * 0.5))
        resized_img = cv2.resize(gray_img, new_dim, interpolation=cv2.INTER_AREA)

        cv2.imwrite(upload_path, resized_img)
        
        dest_key = 'processed-' + key
        s3_client.upload_file(upload_path, destination_bucket, dest_key)
        
        topic_arn = "arn:aws:sns:ap-south-1:123456789012:image-processing-alert"
        
        message = f"Success! Image {key} was processed using OpenCV and saved to {destination_bucket}."
        sns_client.publish(TopicArn=topic_arn, Message=message, Subject="Image Processed")
        
        return {
            'statusCode': 200,
            'body': json.dumps('Image processed successfully!')
        }
        
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing image: {str(e)}")
        }