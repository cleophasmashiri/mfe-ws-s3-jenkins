pipeline {
    agent any
     environment {
        // S3_ENDPOINT_URL = 'http://192.168.0.6:4566'
        S3_ENDPOINT_URL = 'https://s3.eu-north-1.amazonaws.com'
        S3_BUCKET_DEV = 'homeserv-dev'
        AWS_SECRET_ACCESS_KEY = credentials('aws-credentials')
        AWS_REGION = 'eu-north-1'
        DOCKER_NODE_IMAGE_NAME = 'my-custom-node'
        DOCKER_CYPRESS_IMAGE_NAME = 'my-cypress'
        NX_COMMAND = 'nx'
        skip_tests = true
    }
    stages {
        stage('Build') {
            agent {
                docker {
                    image 'my-cypress'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm i --force --verbose
                    $NX_COMMAND reset
                    $NX_COMMAND build dashboard --configuration=production
                    ls -la
                   '''
            }
        }
     
      
        stage('Testing & Linting') {
            parallel {
                stage('Linting') {
                    agent {
                        docker {
                            image 'my-cypress'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            echo "Started Linting"
                            $NX_COMMAND lint hs-customer-dashboard --verbose --format=html --output-file=dist/reports/linting-report.html

                        '''
                    }
                     post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'dist/reports', reportFiles: 'linting-report.html', reportName: 'Linting-Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
                stage('Unit Test') {
                    agent {
                        docker {
                            image 'my-cypress'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                        echo "Running unit tests"
                         # $NX_COMMAND reset
                         $NX_COMMAND test dashboard --ci --codeCoverage --verbose 
                        '''
                    }
                    post {
                        always {
                            // This will visualize the JUnit XML report
                            junit 'reports/junit/js-test-results.xml'
                            //publishHTML([reportName: 'Test Coverage', reportDir: 'coverage/apps/hs-customer-dashboard/feature', reportFiles: 'index.html', keepAll: true])
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'coverage/libs/hs-customer-dashboard/feature', reportFiles: 'index.html', reportName: 'Unit-Tests-Coverage', reportTitles: 'Unit-Tests-Coverage', useWrapperFileDirectly: true])
                            archiveArtifacts artifacts: '**/reports/junit/*.xml', allowEmptyArchive: true
                            archiveArtifacts artifacts: '**/coverage/**', allowEmptyArchive: true
                        }
                    }
                }

                stage('e2e Test') {
                    agent {
                        docker {
                            image 'my-cypress'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                        echo "Running e2e tests"
                        $NX_COMMAND e2e dashboard-e2e --verbose
                        '''
                    }
                    post {
                        always {
                            sh '''
                            find dist/cypress/reports/ -size 0 -print -delete
                            npx mochawesome-merge dist/cypress/reports/*.json > dist/cypress/reports/mochawesome.json
                            npx marge dist/cypress/reports/mochawesome.json -f report -o dist/cypress/reports
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'dist/cypress/reports', reportFiles: 'report.html', reportName: 'e2e-Tests', reportTitles: 'e2e-Tests', useWrapperFileDirectly: true])
                            '''
                        }
                    }
                }
            }
        }
         stage('Terraform Init') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'terraform init'
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
        stage('Deploy App1 to LocalStack S3') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    // sh 'aws --endpoint-url=$S3_ENDPOINT_URL s3 mb s3://$S3_BUCKET_DEV'
                    sh 'aws --endpoint-url=$S3_ENDPOINT_URL s3 sync dist/apps/dashboard s3://dashboard/ --delete'
                }
            }
        }
        // stage('Deploy To Dev') {
        //     agent {
        //         docker {
        //             image 'my-cypress'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''
        //         echo "Deploy"
        //         '''
        //     }
        // }
    }
}
