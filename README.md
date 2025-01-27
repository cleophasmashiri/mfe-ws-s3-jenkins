# MfeWs1

## How to CF templates
```
aws cloudformation create-stack --stack-name cfm-s3-website-func --template-body file://cf-build-basic-func.yml --capabilities CAPABILITY_NAMED_IAM
```

```
aws cloudformation deploy  --stack-name cfm-build-reports --template-file cf-build-basic.yml --capabilities CAPABILITY_NAMED_IAM
```

```
aws cloudformation delete-stack --stack-name cfm-s3-website
```

```
aws cloudformation update-stack --stack-name cfm-workshop --template-body file://lab2.yaml --parameters ParameterKey=DefaultVpcId,ParameterValue=${VPCID}
```

## Run Jenkins
```
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins-docker

```