module.exports = {
  "username": "szymonrichert.pl bot",
  "gitAuthor": "szymonrichert.pl bot <bot@szymonrichert.pl>",
  "onboarding": false,
  "platform": "github",
  "repositories": ["szymonrychu/helmfile-cluster"],
  "dependencyDashboard": false,
  "packageRules": [
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
