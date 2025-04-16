pipeline {
    agent any
    
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        GCP_CREDENTIALS = credentials('gcp-credentials')
        PROJECT_ID = 'devopsuq'
        CLUSTER_NAME = 'microservicios-cluster'
        LOCATION = 'us-central1-a'
        DOCKER_IMAGE_VERSION = "v${BUILD_NUMBER}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }   
        }
        
        stage('Build Microservices') {
            parallel {
                stage('Build Config Server') {
                    steps {
                        dir('configserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Eureka Server') {
                    steps {
                        dir('eurekaserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Gateway Server') {
                    steps {
                        dir('gatewayserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Accounts') {
                    steps {
                        dir('accounts') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Cards') {
                    steps {
                        dir('cards') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Build Loans') {
                    steps {
                        dir('loans') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
            }
        }
        
        stage('Build and Push Docker Images') {
            steps {
                script {
                    // Login to DockerHub
                    sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                    
                    // Build and push each service
                    def services = ['configserver', 'eurekaserver', 'gatewayserver', 'accounts', 'cards', 'loans']
                    services.each { service ->
                        dir(service) {
                            sh """
                                docker build -t juliangiraldo97/${service}:${DOCKER_IMAGE_VERSION} .
                                docker push juliangiraldo97/${service}:${DOCKER_IMAGE_VERSION}
                            """
                        }
                    }
                }
            }
        }
        
        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    def services = ['configserver', 'eurekaserver', 'gatewayserver', 'accounts', 'cards', 'loans']
                    services.each { service ->
                        sh """
                            sed -i 's|juliangiraldo97/${service}:[^ ]*|juliangiraldo97/${service}:${DOCKER_IMAGE_VERSION}|' k8s/${service}/deployment.yaml
                        """
                    }
                }
            }
        }
        
        stage('Deploy to GKE') {
            steps {
                script {
                    // Authenticate to Google Cloud
                    sh '''
                        echo $GCP_CREDENTIALS > gcp-key.json
                        gcloud auth activate-service-account --key-file=gcp-key.json
                        gcloud container clusters get-credentials $CLUSTER_NAME --zone $LOCATION --project $PROJECT_ID
                    '''
                    
                    // Apply Kubernetes manifests
                    sh '''
                        kubectl apply -f k8s/configmap.yaml
                        
                        kubectl apply -f k8s/configserver/deployment.yaml
                        kubectl apply -f k8s/configserver/service.yaml
                        
                        kubectl apply -f k8s/eurekaserver/deployment.yaml
                        kubectl apply -f k8s/eurekaserver/service.yaml
                        
                        kubectl apply -f k8s/gatewayserver/deployment.yaml
                        kubectl apply -f k8s/gatewayserver/service.yaml
                        
                        kubectl apply -f k8s/accounts/deployment.yaml
                        kubectl apply -f k8s/accounts/service.yaml
                        
                        kubectl apply -f k8s/loans/deployment.yaml
                        kubectl apply -f k8s/loans/service.yaml
                        
                        kubectl apply -f k8s/cards/deployment.yaml
                        kubectl apply -f k8s/cards/service.yaml
                    '''
                }
            }
        }
    }
    
    post {
        always {
            sh 'docker logout'
            sh 'rm -f gcp-key.json'
        }
    }
}