pipeline {
    agent none

    stages {
        stage('Tests') {
            parallel {
                stage('ruby 2.2') {
                    agent { docker { image 'ruby:2.2' } }
                    steps {
                        sh 'bundle'
                        sh "bundle exec rake spec"
                    }
                }
                stage('ruby 2.3') {
                    agent { docker { image 'ruby:2.3' } }
                    steps {
                        sh 'bundle'
                        sh "bundle exec rake spec"
                    }
                }
                stage('ruby 2.4') {
                    agent { docker { image 'ruby:2.4' } }
                    steps {
                        sh 'bundle'
                        sh "bundle exec rake spec"
                    }
                }
                stage('ruby 2.5') {
                    agent { docker { image 'ruby:2.5' } }
                    steps {
                        sh 'bundle'
                        sh "bundle exec rake spec"
                    }
                }
            }
        }
    }

    post {
        success {
            updateGitlabCommitStatus(name: 'jenkins-build', state: 'success')
            mattermostSend endpoint: "${MATTERMOST_PUPPET_AUDITOR_ENDPOINT}", channel: "${MATTERMOST_PUPPET_AUDITOR_CHANNEL}", color: '#00b900', message: ":white_check_mark:  **${env.JOB_NAME}** Success! [Check build #${env.BUILD_NUMBER}](${env.BUILD_URL})", text: "**Build #${env.BUILD_NUMBER} - ${env.JOB_NAME}**  Success!"
        }
        unstable {
            updateGitlabCommitStatus(name: 'jenkins-build', state: 'failed')
            mattermostSend endpoint: "${MATTERMOST_PUPPET_AUDITOR_ENDPOINT}", channel: "${MATTERMOST_PUPPET_AUDITOR_CHANNEL}", color: '#ffc700', message: ":warning:  **${env.JOB_NAME}** Unstable! [Check build #${env.BUILD_NUMBER}](${env.BUILD_URL})", text: "**Build #${env.BUILD_NUMBER} - ${env.JOB_NAME}**  Unstable!"
        }
        failure {
            updateGitlabCommitStatus(name: 'jenkins-build', state: 'failed')
            mattermostSend endpoint: "${MATTERMOST_PUPPET_AUDITOR_ENDPOINT}", channel: "${MATTERMOST_PUPPET_AUDITOR_CHANNEL}", color: '#ff2a00', message: ":x:  **${env.JOB_NAME}** Failure! [Check build #${env.BUILD_NUMBER}](${env.BUILD_URL})", text: "**Build #${env.BUILD_NUMBER} - ${env.JOB_NAME}**  Failure!"
        }
    }
}
