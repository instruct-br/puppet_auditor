pipeline {
    agent any

    stages {
        stage('Build'){
            steps {
                sh 'bundle'
            }
        }

        stage('Test') {
            steps {
                sh "bundle exec rake spec"
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
        always {
            deleteDir()
        }
    }
}
