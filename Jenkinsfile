pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "tarun142333"
        IMAGE_NAME      = "my-jenkins-app"
        DOCKER_HUB_CREDS = 'dockerhub-creds'
    }

    stages {
        stage('1. Cleanup & Checkout') {
            steps {
                // Clear any old junk from previous failed builds
                sh 'docker system prune -f'
                checkout scm
            }
        }

        stage('2. SAST Scan (Trivy)') {
            steps {
                script {
                    echo "--- SCANNING FOR VULNERABILITIES ---"
                    // We run the scan and then immediately remove the container
                    sh 'docker run --rm -v $(pwd):/root aquasec/trivy fs --exit-code 1 --severity CRITICAL /root'
                }
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo "Building: ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                // We use --no-cache to keep the disk clean
                sh "docker build --no-cache -t ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('4. Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_CREDS,
                                     passwordVariable: 'PASS',
                                     usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                        sh "docker tag ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest"
                        sh "docker push ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            // Final cleanup of the workspace and local images
            cleanWs()
            sh "docker rmi ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} || true"
            sh "docker rmi ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest || true"
            // Special command to clear the hidden Trivy cache files
            sh "rm -rf .cache"
        }
    }
}