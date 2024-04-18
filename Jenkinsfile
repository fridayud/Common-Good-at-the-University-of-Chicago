pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-username/your-repo.git' // Replace with your repository URL
            }
        }

        stage('Initialize Terraform') {
            steps {
                script {
                    dir('terraform') { // Assuming your Terraform files are in a directory called 'terraform'
                        terraform("init")
                    }
                }
            }
        }

        stage('Apply Terraform') {
            steps {
                script {
                    dir('terraform') {
                        terraform("apply -auto-approve")
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                deleteDir() // Clean up the workspace after the run
            }
        }
    }

    post {
        always {
            script {
                dir('terraform') {
                    terraform("destroy -auto-approve") // Optional: Remove all Terraform-managed infrastructure
                }
            }
        }

        success {
            echo 'Deployment succeeded!'
        }

        failure {
            echo 'Deployment failed.'
        }

        changed {
            echo 'Something has changed in the Deployment.'
        }
    }
}
