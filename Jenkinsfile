pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REGISTRY = '975050176026.dkr.ecr.us-east-1.amazonaws.com'
        ECR_REPOSITORY = 'my-ecr-repo'
        IMAGE_TAG = "${BUILD_ID}"
        KUBE_NAMESPACE = 'Default'  
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Mohamed0essam/DEPI-DevOps-Project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dir('app') {
                        dockerImage = docker.build("${ECR_REPOSITORY}:${IMAGE_TAG}")
                    }
                }
            }
        }

        stage('Tag & Push Image to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-ecr-credentials']]) {
                        sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
                        docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} $ECR_REGISTRY/${ECR_REPOSITORY}:${IMAGE_TAG}
                        docker push $ECR_REGISTRY/${ECR_REPOSITORY}:${IMAGE_TAG}
                        '''
                    }
                }
            }
        }

      stage('Deploy to Kubernetes') {
    steps {
        withCredentials([file(credentialsId: 'secret_key', variable: 'Secretfile')]) {
            script {
                sh '''
                    mkdir -p ~/.ssh
                    ssh-keyscan -H 34.229.163.123 >> ~/.ssh/known_hosts
                    cat ~/.ssh/known_hosts  # Log known hosts for debugging

                    # Check if the SSH key is present
                    if [ -f "${Secretfile}" ]; then
                        echo "Secret file exists."
                    else
                        echo "Secret file does not exist."
                        exit 1
                    fi
                    
                    # Attempt SSH connection with verbose output
                    ssh -o StrictHostKeyChecking=no -vvv -i "${Secretfile}" ubuntu@34.229.163.123 << EOF
                        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_REGISTRY
                        kubectl set image deployment/python-deployment python-container=$ECR_REGISTRY/my-ecr-repo:${IMAGE_TAG} -n ${KUBE_NAMESPACE} --record
                        kubectl rollout restart deployment/python-deployment -n ${KUBE_NAMESPACE}
                    EOF
                '''
            }
        }
    }
}

    }

    post {
        always {
            cleanWs()
        }
    }
}
