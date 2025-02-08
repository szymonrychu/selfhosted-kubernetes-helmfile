module.exports = {
  "semanticCommits": "enabled",
  "extends": ["config:recommended", ":rebaseStalePrs"],
  "dependencyDashboard": false,
  "suppressNotifications": ["prIgnoreNotification"],
  "commitMessageTopic": "{{depName}}",
  "commitMessageExtra": "to {{newVersion}}",
  "commitMessageSuffix": "",
  "rebaseWhen": "conflicted",
  "username": "szymonrichert.pl bot",
  "pinDigests": true,
  "automerge": true,
  "gitAuthor": "szymonrichert.pl bot <bot@szymonrichert.pl>",
  "dependencyDashboard": false,
  "platform": "gitlab",
  "endpoint": process.env.CI_API_V4_URL,
  "token": process.env.BOT_TOKEN,
  "onboarding": false,
  "onboardingConfig": {
    extends: ['config:recommended'],
  },
  "repositories": [process.env.CI_PROJECT_PATH]
};
