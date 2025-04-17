pipeline {
    agent any

    environment {
        IMAGE_NAME = "juliangiraldo97/loans-service"
        IMAGE_TAG = "latest"
    }

    stages {
        stage('Login to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        echo "[INFO] Docker login status:"
                        docker info
                    '''
                }
            }
        }

        stage('Build loans-service') {
            steps {
                sh '''
                    echo "[INFO] Building image: $IMAGE_NAME:$IMAGE_TAG"
                    DOCKER_BUILDKIT=1 docker build -t $IMAGE_NAME:$IMAGE_TAG ./loans
                '''
            }
        }

        stage('Push loans-service') {
            steps {
                sh '''
                    echo "[INFO] Pushing image: $IMAGE_NAME:$IMAGE_TAG"
                    docker push $IMAGE_NAME:$IMAGE_TAG
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout'
        }
    }
}
