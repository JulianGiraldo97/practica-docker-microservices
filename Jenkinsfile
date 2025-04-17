pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub')
        PROJECT_ID = 'devopsuq'
        CLUSTER_NAME = 'microservicios-cluster'
        LOCATION = 'us-central1-a'
        DOCKER_IMAGE_VERSION = "v${BUILD_NUMBER}"
        DOCKER_BUILDKIT = '1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Microservices') {
            parallel {
                stage('Config Server') {
                    steps {
                        dir('configserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Eureka Server') {
                    steps {
                        dir('eurekaserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Gateway Server') {
                    steps {
                        dir('gatewayserver') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Accounts') {
                    steps {
                        dir('accounts') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Cards') {
                    steps {
                        dir('cards') {
                            sh 'mvn clean package -DskipTests'
                        }
                    }
                }
                stage('Loans') {
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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'

                        def services = [
                            'configserver': 'configserver',
                            'eurekaserver': 'eurekaserver',
                            'gatewayserver': 'gatewayserver',
                            'accounts': 'accounts-service',
                            'cards': 'cards-service',
                            'loans': 'loans-service'
                        ]

                        parallel services.collectEntries { dirName, dockerName ->
                            ["${dirName}" : {
                                dir(dirName) {
                                    def imageName = "juliangiraldo97/${dockerName}:${DOCKER_IMAGE_VERSION}"

                                    sh """
                                        echo ">> Building image ${imageName}"
                                        docker build -t ${imageName} .
                                    """

                                    def exists = sh(
                                        script: "curl --silent -f -lSL https://hub.docker.com/v2/repositories/juliangiraldo97/${dockerName}/tags/${DOCKER_IMAGE_VERSION}/ > /dev/null && echo true || echo false",
                                        returnStdout: true
                                    ).trim()

                                    if (exists == "false") {
                                        sh "docker push ${imageName}"
                                    } else {
                                        echo ">> Image ${imageName} already exists, skipping push"
                                    }
                                }
                            }]
                        }

                        sh 'docker logout'
                    }
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                script {
                    def services = [
                        'configserver': 'configserver',
                        'eurekaserver': 'eurekaserver',
                        'gatewayserver': 'gatewayserver',
                        'accounts': 'accounts-service',
                        'cards': 'cards-service',
                        'loans': 'loans-service'
                    ]
                    services.each { dirName, dockerName ->
                        sh """
                            sed -i 's|juliangiraldo97/${dockerName}:[^ ]*|juliangiraldo97/${dockerName}:${DOCKER_IMAGE_VERSION}|' k8s/${dirName}/deployment.yaml
                        """
                    }
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                withCredentials([file(credentialsId: 'gcp-credentials', variable: 'GCP_KEY')]) {
                    script {
                        sh '''
                            gcloud auth activate-service-account --key-file=$GCP_KEY
                            gcloud container clusters get-credentials $CLUSTER_NAME --zone $LOCATION --project $PROJECT_ID

                            kubectl apply -f k8s/configmap.yaml

                            for service in configserver eurekaserver gatewayserver accounts loans cards; do
                                kubectl apply -f k8s/$service/deployment.yaml
                                kubectl apply -f k8s/$service/service.yaml
                            done
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
