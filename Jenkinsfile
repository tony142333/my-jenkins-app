pipeline {
    agent any

    environment {
        DOCKER_HUB_USER = "tarun142333"
        IMAGE_NAME      = "my-jenkins-app"
        DOCKER_HUB_CREDS = 'dockerhub-creds'
    }

    stages {
        stage('0. Clean Environment') {
            steps {
                echo "Wiping old Docker artifacts to free up space..."
                // -f means 'force' (don't ask me for permission)
                sh 'docker system prune -f'
            }
        }

        stage('1. Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('2. SAST Scan (Security)') {
            steps {
                script {
                    echo "--- STARTING SAST SCAN ---"
                    // We add '--reset' or use a dedicated cache folder to keep the disk light
                    sh 'docker run --rm -v $(pwd):/root -v /tmp/trivy-cache:/.cache aquasec/trivy fs --exit-code 1 --severity CRITICAL /root'
                    echo "--- SAST SCAN PASSED ---"
                }
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo "Building Docker Image: ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER}"
                // We use --no-cache to ensure we don't accidentally fill the disk with intermediate layers
                sh "docker build --no-cache -t ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} ."
            }
        }

        stage('4. Ship to Warehouse') {
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
            // This is CRITICAL for small disks. It deletes the code after the build is done.
            cleanWs()
            // Removes the image we just built from the LOCAL EC2 so the next build has space
            sh "docker rmi ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:${env.BUILD_NUMBER} || true"
            sh "docker rmi ${env.DOCKER_HUB_USER}/${env.IMAGE_NAME}:latest || true"
        }
    }
}