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
  "dependencyDashboard": false,
  "packageRules": [
    {
      "matchManagers": ["github-actions"],
      "commitMessageTopic": "github-action {{depName}}",
    },
    {
      "description": "MinorAutoUpgrade",
      "matchUpdateTypes": ["pin", "digest", "patch", "minor", "major"],
      "minimumReleaseAge": null
    },
    {
      "description": "MajorUpgrade",
      "matchUpdateTypes": ["major"],
      "minimumReleaseAge": "7 days"
    }
  ]
};
