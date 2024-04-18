import json

def lambda_handler(event, context):
    # Your code here
    print("Hello, Lambda!")
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
