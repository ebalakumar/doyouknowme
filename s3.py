import boto3

session = boto3.Session(profile_name='personal')
s3 = session.resource('s3')
print(s3.meta.client.upload_file('pic/pokemon.jpeg', 'doyouknowme', 'pokemon.jpg'))
