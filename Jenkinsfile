pipeline {
    agent any

    environment {
        // Replace with your Docker Hub details
        DOCKER_HUB_USER = "tarun142333"
        IMAGE_NAME      = "my-jenkins-app"
        DOCKER_HUB_CREDS = 'dockerhub-creds' // The ID you gave your credentials in the Jenkins UI
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                // This pulls your code from GitHub onto the AWS server
                checkout scm
            }
        }

        stage('2. SAST Scan (Security)') {
            steps {
                script {
                    echo "--- STARTING SAST SCAN ---"
                    // We use Trivy to scan the local filesystem ('fs')
                    // --exit-code 1: If it finds a CRITICAL bug, it fails the build
                    // --severity CRITICAL: Only stop for the worst stuff
                    sh 'docker run --rm -v $(pwd):/root aquasec/trivy fs --exit-code 1 --severity CRITICAL /root'
                    echo "--- SAST SCAN PASSED ---"
                }
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo "Building Docker Image: ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                sh "docker build -t ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('4. Ship to Warehouse') {
            steps {
                script {
                    // This pulls the "keys" from the Jenkins vault we set up
                    withCredentials([usernamePassword(credentialsId: env.DOCKER_HUB_CREDS,
                                     passwordVariable: 'PASS',
                                     usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"

                        // Also update the 'latest' tag
                        sh "docker tag ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest"
                        sh "docker push ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest"
                    }
                }
            }
        }
    }

    post {
        always {
            // Cleans up the workspace so your EC2 disk doesn't fill up
            cleanWs()
        }
        failure {
            echo "Pipeline failed! Check the SAST logs for security vulnerabilities."
        }
    }
}


