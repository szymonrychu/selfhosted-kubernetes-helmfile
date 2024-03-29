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
  "onboarding": false,
  "platform": "github",
  "repositories": ["szymonrychu/selfhosted-kubernetes-helmfile"],
  "dependencyDashboard": false
};
